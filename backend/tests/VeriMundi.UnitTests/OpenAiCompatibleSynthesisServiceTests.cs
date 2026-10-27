using System.Net;
using System.Text;
using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using VeriMundi.Application.Abstractions;
using VeriMundi.Infrastructure.Ai;

namespace VeriMundi.UnitTests;

public class OpenAiCompatibleSynthesisServiceTests
{
    [Fact]
    public async Task Synthesise_uses_provider_json_when_http_succeeds()
    {
        var handler = new StubHandler("""
            {"choices":[{"message":{"content":"{\"summary\":\"Clinic expands evening hours.\",\"whyItMatters\":\"Access.\",\"confirmedFacts\":[{\"text\":\"Evening hours expand\",\"sourceIds\":[\"src-a\"]}],\"disputedClaims\":[],\"uncertainties\":[\"Start date TBD\"],\"severity\":\"developing\",\"severityReason\":\"Service change\",\"tone\":\"positive\",\"confidenceScore\":0.7,\"insufficientEvidence\":false}"}}]}
            """);
        var service = CreateService(handler);

        var result = await service.SynthesiseAsync(new AiSynthesisRequest(
            Guid.NewGuid(),
            "Clinic expands hours",
            [new AiSourceEvidence(Guid.NewGuid(), "src-a", "Local", "Clinic expands hours", "Evening hours", "local")]));

        result.InsufficientEvidence.Should().BeFalse();
        result.Summary.Should().Contain("Clinic expands");
        result.ConfirmedFacts.Should().ContainSingle(f => f.SourceIds.Contains("src-a"));
        handler.LastRequestUri.Should().NotBeNull();
        handler.LastRequestUri!.AbsolutePath.Should().EndWith("/chat/completions");
        handler.LastAuthorization.Should().Be("Bearer test-key");
    }

    [Fact]
    public async Task Ask_falls_back_to_heuristic_when_provider_fails()
    {
        var handler = new StubHandler("boom", HttpStatusCode.ServiceUnavailable);
        var service = CreateService(handler);
        var evidence = new AiSourceEvidence(Guid.NewGuid(), "src-a", "Local", "Clinic", "Hours expand", "local");

        var result = await service.AnswerQuestionAsync(new AiQuestionRequest(
            Guid.NewGuid(),
            "Why does this matter?",
            "Clinic expands hours",
            "Hours expand next month.",
            [evidence],
            [],
            []));

        result.InsufficientEvidence.Should().BeFalse();
        result.Uncertainty.Should().Contain("GenAI provider unavailable");
        result.SourceIds.Should().Contain("src-a");
    }

    private static OpenAiCompatibleSynthesisService CreateService(StubHandler handler)
    {
        var factory = new StubHttpClientFactory(handler);
        var opts = Options.Create(new AiOptions
        {
            ApiKey = "test-key",
            BaseUrl = "https://example.test/v1",
            Model = "test-model"
        });
        return new OpenAiCompatibleSynthesisService(
            factory,
            opts,
            new HeuristicAiSynthesisService(),
            NullLogger<OpenAiCompatibleSynthesisService>.Instance);
    }

    private sealed class StubHttpClientFactory(StubHandler handler) : IHttpClientFactory
    {
        public HttpClient CreateClient(string name)
        {
            var client = new HttpClient(handler)
            {
                BaseAddress = new Uri("https://example.test/v1/", UriKind.Absolute)
            };
            return client;
        }
    }

    private sealed class StubHandler(string body, HttpStatusCode status = HttpStatusCode.OK) : HttpMessageHandler
    {
        public Uri? LastRequestUri { get; private set; }
        public string? LastAuthorization { get; private set; }

        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            LastRequestUri = request.RequestUri;
            LastAuthorization = request.Headers.Authorization?.ToString();
            var response = new HttpResponseMessage(status)
            {
                Content = new StringContent(body, Encoding.UTF8, "application/json")
            };
            return Task.FromResult(response);
        }
    }
}
