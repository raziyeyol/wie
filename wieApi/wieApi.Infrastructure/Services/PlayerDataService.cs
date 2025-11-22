using Microsoft.EntityFrameworkCore;
using wieApi.Application.DTOs;
using wieApi.Application.Interfaces;
using wieApi.Domain.Entities;
using wieApi.Infrastructure.Persistence;

namespace wieApi.Infrastructure.Services;

public class PlayerDataService : IPlayerDataService
{
    private readonly WordsLearningDbContext _dbContext;

    public PlayerDataService(WordsLearningDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<UserProfileDto?> GetUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await _dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == userId, cancellationToken);
        if (user is null)
        {
            return null;
        }

        var latestSnapshot = await GetSnapshotQuery(userId)
            .AsNoTracking()
            .FirstOrDefaultAsync(cancellationToken);

        return MapToDto(user, latestSnapshot);
    }

    public async Task<UserProfileDto> CreateUserAsync(CreateUserRequest request, CancellationToken cancellationToken = default)
    {
        var user = new User
        {
            DisplayName = request.DisplayName,
            AvatarUrl = request.AvatarUrl,
            CreatedAtUtc = DateTime.UtcNow
        };

        await _dbContext.Users.AddAsync(user, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return MapToDto(user, null);
    }

    public async Task<UserProfileDto?> UpdateUserAsync(Guid userId, UpdateUserRequest request, CancellationToken cancellationToken = default)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(x => x.Id == userId, cancellationToken);
        if (user is null)
        {
            return null;
        }

        user.DisplayName = request.DisplayName;
        user.AvatarUrl = request.AvatarUrl;

        await _dbContext.SaveChangesAsync(cancellationToken);

        var latestSnapshot = await GetSnapshotQuery(userId)
            .AsNoTracking()
            .FirstOrDefaultAsync(cancellationToken);

        return MapToDto(user, latestSnapshot);
    }

    public async Task<ProgressSnapshotDto?> GetLatestProgressAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var snapshot = await GetSnapshotQuery(userId)
            .AsNoTracking()
            .FirstOrDefaultAsync(cancellationToken);

        return snapshot is null ? null : MapSnapshot(snapshot);
    }

    public async Task<ProgressSnapshotDto> UpsertProgressAsync(UpsertProgressRequest request, CancellationToken cancellationToken = default)
    {
        var snapshot = new UserProgressSnapshot
        {
            UserId = request.UserId,
            TotalStars = request.TotalStars,
            TotalPoints = request.TotalPoints,
            WordsPracticed = request.WordsPracticed,
            BadgesCsv = string.Join(',', request.Badges ?? Array.Empty<string>()),
            CapturedAtUtc = DateTime.UtcNow
        };

        await _dbContext.ProgressSnapshots.AddAsync(snapshot, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return MapSnapshot(snapshot);
    }

    public async Task<IReadOnlyCollection<ScoreDto>> GetScoresAsync(Guid userId, string? gameMode, CancellationToken cancellationToken = default)
    {
        var query = _dbContext.Scores
            .Where(score => score.UserId == userId)
            .AsNoTracking();

        if (!string.IsNullOrWhiteSpace(gameMode))
        {
            query = query.Where(score => score.GameMode == gameMode);
        }

        var scores = await query
            .OrderByDescending(score => score.CompletedAtUtc)
            .ToListAsync(cancellationToken);

        return scores.Select(MapScore).ToList();
    }

    public async Task<ScoreDto> AddScoreAsync(CreateScoreRequest request, CancellationToken cancellationToken = default)
    {
        var score = new Score
        {
            UserId = request.UserId,
            GameMode = request.GameMode,
            Points = request.Points,
            Stars = request.Stars,
            Duration = TimeSpan.FromSeconds(request.DurationSeconds),
            CompletedAtUtc = DateTime.UtcNow,
            MetadataJson = request.MetadataJson
        };

        await _dbContext.Scores.AddAsync(score, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return MapScore(score);
    }

    private IQueryable<UserProgressSnapshot> GetSnapshotQuery(Guid userId)
    {
        return _dbContext.ProgressSnapshots
            .Where(snapshot => snapshot.UserId == userId)
            .OrderByDescending(snapshot => snapshot.CapturedAtUtc);
    }

    private static UserProfileDto MapToDto(User user, UserProgressSnapshot? snapshot)
    {
        var badges = snapshot is null
            ? Array.Empty<string>()
            : SplitBadges(snapshot.BadgesCsv);

        return new UserProfileDto(
            user.Id,
            user.DisplayName,
            user.AvatarUrl,
            user.CreatedAtUtc,
            snapshot?.TotalStars ?? 0,
            snapshot?.TotalPoints ?? 0,
            snapshot?.WordsPracticed ?? 0,
            badges);
    }

    private static ProgressSnapshotDto MapSnapshot(UserProgressSnapshot snapshot)
    {
        return new ProgressSnapshotDto(
            snapshot.Id,
            snapshot.UserId,
            snapshot.TotalStars,
            snapshot.TotalPoints,
            snapshot.WordsPracticed,
            SplitBadges(snapshot.BadgesCsv),
            snapshot.CapturedAtUtc);
    }

    private static ScoreDto MapScore(Score score)
    {
        return new ScoreDto(
            score.Id,
            score.UserId,
            score.GameMode,
            score.Points,
            score.Stars,
            score.Duration.TotalSeconds,
            score.CompletedAtUtc,
            score.MetadataJson);
    }

    private static string[] SplitBadges(string? csv)
    {
        return string.IsNullOrWhiteSpace(csv)
            ? Array.Empty<string>()
            : csv!
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
    }
}
