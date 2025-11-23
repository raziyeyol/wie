using Microsoft.Extensions.DependencyInjection;
using wieApi.Application.Interfaces;
using wieApi.Application.Services;

namespace wieApi.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<IWordLevelService, WordLevelService>();
        return services;
    }
}
