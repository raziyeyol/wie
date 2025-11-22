using wieApi.Application.DTOs;

namespace wieApi.Application.Interfaces;

public interface IPlayerDataService
{
    Task<UserProfileDto?> GetUserAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<UserProfileDto> CreateUserAsync(CreateUserRequest request, CancellationToken cancellationToken = default);
    Task<UserProfileDto?> UpdateUserAsync(Guid userId, UpdateUserRequest request, CancellationToken cancellationToken = default);

    Task<ProgressSnapshotDto?> GetLatestProgressAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<ProgressSnapshotDto> UpsertProgressAsync(UpsertProgressRequest request, CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<ScoreDto>> GetScoresAsync(Guid userId, string? gameMode, CancellationToken cancellationToken = default);
    Task<ScoreDto> AddScoreAsync(CreateScoreRequest request, CancellationToken cancellationToken = default);
}
