using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using wieApi.Domain.Entities;
using wieApi.Infrastructure.Persistence;

namespace wieApi.Infrastructure.Seed;

public static class DataSeeder
{
    public static async Task SeedAsync(WordsLearningDbContext context, ILogger logger, CancellationToken cancellationToken = default)
    {
        if (!await context.WordLevels.AnyAsync(cancellationToken))
        {
            var levels = WordSeedData.BuildLevels();
            await context.WordLevels.AddRangeAsync(levels, cancellationToken);
            await context.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Seeded {Count} word levels", levels.Count);
        }

        if (!await context.Users.AnyAsync(cancellationToken))
        {
            var demoUser = new User
            {
                DisplayName = "Demo Learner",
                AvatarUrl = null,
                CreatedAtUtc = DateTime.UtcNow
            };

            await context.Users.AddAsync(demoUser, cancellationToken);
            await context.ProgressSnapshots.AddAsync(new UserProgressSnapshot
            {
                UserId = demoUser.Id,
                TotalPoints = 0,
                TotalStars = 0,
                WordsPracticed = 0,
                BadgesCsv = string.Empty,
                CapturedAtUtc = DateTime.UtcNow
            }, cancellationToken);

            await context.Scores.AddAsync(new Score
            {
                UserId = demoUser.Id,
                GameMode = "WordSearch",
                Points = 0,
                Stars = 0,
                Duration = TimeSpan.Zero,
                CompletedAtUtc = DateTime.UtcNow,
                MetadataJson = "{}"
            }, cancellationToken);

            await context.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Seeded demo user and related progress records");
        }
    }
}
