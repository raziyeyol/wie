using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using wieApi.Application.Interfaces;
using wieApi.Infrastructure.Persistence;
using wieApi.Infrastructure.Repositories;
using wieApi.Infrastructure.Services;

namespace wieApi.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var sqliteBuilder = new SqliteConnectionStringBuilder(
            configuration.GetConnectionString("wie") ?? "Data Source=Data/wie.db");

        if (!Path.IsPathRooted(sqliteBuilder.DataSource))
        {
            sqliteBuilder.DataSource = Path.Combine(AppContext.BaseDirectory, sqliteBuilder.DataSource);
        }

        var dataDirectory = Path.GetDirectoryName(sqliteBuilder.DataSource);
        if (!string.IsNullOrWhiteSpace(dataDirectory))
        {
            Directory.CreateDirectory(dataDirectory);
        }

        services.AddDbContext<WieDbContext>(options =>
        {
            options.UseSqlite(sqliteBuilder.ToString());
        });

        services.AddScoped<IWordLevelRepository, WordLevelRepository>();
        services.AddScoped<IPlayerDataService, PlayerDataService>();

        return services;
    }
}
