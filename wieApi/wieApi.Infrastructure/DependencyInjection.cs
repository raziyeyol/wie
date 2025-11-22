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
            configuration.GetConnectionString("WordsLearning") ?? "Data Source=Data/wordslearning.db");

        if (!Path.IsPathRooted(sqliteBuilder.DataSource))
        {
            sqliteBuilder.DataSource = Path.Combine(AppContext.BaseDirectory, sqliteBuilder.DataSource);
        }

        var dataDirectory = Path.GetDirectoryName(sqliteBuilder.DataSource);
        if (!string.IsNullOrWhiteSpace(dataDirectory))
        {
            Directory.CreateDirectory(dataDirectory);
        }

        services.AddDbContext<WordsLearningDbContext>(options =>
        {
            options.UseSqlite(sqliteBuilder.ToString());
        });

        services.AddScoped<IWordLevelRepository, WordLevelRepository>();
        services.AddScoped<IPlayerDataService, PlayerDataService>();

        return services;
    }
}
