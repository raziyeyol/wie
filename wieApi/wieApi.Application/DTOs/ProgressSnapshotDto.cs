namespace wieApi.Application.DTOs;

public record ProgressSnapshotDto(
    Guid Id,
    Guid UserId,
    int TotalStars,
    int TotalPoints,
    int WordsPracticed,
    IReadOnlyCollection<string> Badges,
    DateTime CapturedAtUtc);
