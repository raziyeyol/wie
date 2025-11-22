using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using wieApi.Application.DTOs;
using wieApi.Application.Interfaces;
using wieApi.Application.Services;
using wieApi.Application.Validators;

namespace wieApi.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<IWordLevelService, WordLevelService>();
        services.AddScoped<IValidator<CreateWordLevelRequest>, CreateWordLevelRequestValidator>();
        return services;
    }
}
