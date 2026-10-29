using System.Security.Cryptography;
using System.Text;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Options;

namespace VeriMundi.Api.Security;

/// <summary>
/// Validates the ops shared secret for admin ingestion triggers.
/// </summary>
public static class OpsAdminAuth
{
    public const string HeaderName = "X-VeriMundi-Ops-Token";

    public static bool TryAuthorize(
        HttpRequest request,
        OpsAuthOptions options,
        IHostEnvironment environment,
        out IResult? failure)
    {
        var expected = options.AdminIngestionToken?.Trim();
        var configured = !string.IsNullOrEmpty(expected);

        if (!configured)
        {
            if (environment.IsDevelopment() || environment.IsEnvironment("Testing"))
            {
                failure = null;
                return true;
            }

            failure = Results.Json(
                new ApiError(
                    "ops_auth_misconfigured",
                    "Admin ingestion is locked until Ops:AdminIngestionToken is configured."),
                statusCode: StatusCodes.Status401Unauthorized);
            return false;
        }

        var provided = ExtractToken(request);
        if (provided is null || !FixedTimeEquals(provided, expected!))
        {
            failure = Results.Json(
                new ApiError(
                    "ops_unauthorized",
                    "Valid ops token required. Send X-VeriMundi-Ops-Token or Authorization: Bearer."),
                statusCode: StatusCodes.Status401Unauthorized);
            return false;
        }

        failure = null;
        return true;
    }

    public static string? ExtractToken(HttpRequest request)
    {
        if (request.Headers.TryGetValue(HeaderName, out var headerValues))
        {
            var header = headerValues.FirstOrDefault();
            if (!string.IsNullOrWhiteSpace(header))
            {
                return header.Trim();
            }
        }

        var auth = request.Headers.Authorization.FirstOrDefault();
        if (string.IsNullOrWhiteSpace(auth))
        {
            return null;
        }

        const string bearer = "Bearer ";
        if (auth.StartsWith(bearer, StringComparison.OrdinalIgnoreCase))
        {
            var token = auth[bearer.Length..].Trim();
            return string.IsNullOrEmpty(token) ? null : token;
        }

        return null;
    }

    public static bool FixedTimeEquals(string left, string right)
    {
        var a = Encoding.UTF8.GetBytes(left);
        var b = Encoding.UTF8.GetBytes(right);
        return a.Length == b.Length && CryptographicOperations.FixedTimeEquals(a, b);
    }
}
