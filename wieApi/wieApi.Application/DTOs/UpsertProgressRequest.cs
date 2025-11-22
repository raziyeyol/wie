namespace wieApi.Application.DTOs;

public record UpsertProgressRequest(
    Guid UserId,
    int TotalStars,
    int TotalPoints,
    int WordsPracticed,
    IReadOnlyCollection<string> Badges);
