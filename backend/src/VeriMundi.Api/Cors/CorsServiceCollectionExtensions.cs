using VeriMundi.Api.Options;
using VeriMundi.Api.Security;

namespace VeriMundi.Api.Cors;

public static class CorsServiceCollectionExtensions
{
    public static IServiceCollection AddVeriMundiCors(
        this IServiceCollection services,
        IConfiguration configuration,
        IHostEnvironment environment)
    {
        services.Configure<CorsOptions>(configuration.GetSection(CorsOptions.SectionName));

        var corsSection = configuration.GetSection(CorsOptions.SectionName);
        var allowedOrigins = CorsOriginParser.Parse(corsSection.GetSection("AllowedOrigins"));

        services.AddCors(options =>
        {
            options.AddDefaultPolicy(policy =>
            {
                policy.AllowAnyHeader().AllowAnyMethod();

                if (ProductionStartupGuards.IsHardenedEnvironment(environment))
                {
                    // Staging/Production: explicit allowlist only — never AllowAnyOrigin.
                    ProductionStartupGuards.EnsureCorsAllowlist(allowedOrigins);
                    policy.WithOrigins(allowedOrigins);
                }
                else
                {
                    // Development / Testing (and other local-like envs): permissive for DX.
                    policy.AllowAnyOrigin();
                }
            });
        });

        return services;
    }
}
