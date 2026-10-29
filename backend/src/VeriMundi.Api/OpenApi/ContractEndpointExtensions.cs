using VeriMundi.Api.Contracts;

namespace VeriMundi.Api.OpenApi;

/// <summary>OpenAPI metadata for schema-locked product endpoints.</summary>
public static class ContractEndpointExtensions
{
    public static RouteHandlerBuilder WithStoryPageContract(this RouteHandlerBuilder builder) =>
        builder
            .Produces<PagedResponse<StoryDto>>(StatusCodes.Status200OK)
            .Produces<ApiError>(StatusCodes.Status503ServiceUnavailable);

    public static RouteHandlerBuilder WithStoryItemContract(this RouteHandlerBuilder builder) =>
        builder
            .Produces<StoryDto>(StatusCodes.Status200OK)
            .Produces<ApiError>(StatusCodes.Status400BadRequest)
            .Produces<ApiError>(StatusCodes.Status404NotFound)
            .Produces<ApiError>(StatusCodes.Status503ServiceUnavailable);

    public static RouteHandlerBuilder WithAskContract(this RouteHandlerBuilder builder) =>
        builder
            .Accepts<QuestionRequest>("application/json")
            .Produces<QuestionResponse>(StatusCodes.Status200OK)
            .Produces<ApiError>(StatusCodes.Status400BadRequest)
            .Produces<ApiError>(StatusCodes.Status404NotFound)
            .Produces<ApiError>(StatusCodes.Status429TooManyRequests)
            .Produces<ApiError>(StatusCodes.Status503ServiceUnavailable);

    public static RouteHandlerBuilder WithAppConfigContract(this RouteHandlerBuilder builder) =>
        builder.Produces<AppConfigDto>(StatusCodes.Status200OK);
}
