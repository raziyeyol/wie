namespace wieApi.Application.DTOs;

public record UserProfileDto(
    Guid Id,
    string DisplayName,
    string? AvatarUrl,
    DateTime CreatedAtUtc,
    int TotalStars,
    int TotalPoints,
    int WordsPracticed,
    IReadOnlyCollection<string> Badges);
