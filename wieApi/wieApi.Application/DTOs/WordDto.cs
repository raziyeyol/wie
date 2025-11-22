namespace wieApi.Application.DTOs;

public record WordDto(
    Guid Id,
    Guid LevelId,
    string Text,
    string? AudioKey,
    int SortOrder,
    IReadOnlyCollection<string> Tags);
