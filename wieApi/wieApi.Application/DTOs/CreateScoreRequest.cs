namespace wieApi.Application.DTOs;

public record CreateScoreRequest(
    Guid UserId,
    string GameMode,
    int Points,
    int Stars,
    double DurationSeconds,
    string? MetadataJson);
