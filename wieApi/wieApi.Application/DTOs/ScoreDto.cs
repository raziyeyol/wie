namespace wieApi.Application.DTOs;

public record ScoreDto(
    Guid Id,
    Guid UserId,
    string GameMode,
    int Points,
    int Stars,
    double DurationSeconds,
    DateTime CompletedAtUtc,
    string? MetadataJson);
