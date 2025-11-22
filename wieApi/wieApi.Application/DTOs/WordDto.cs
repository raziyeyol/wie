namespace wieApi.Application.DTOs;

public record WordDto(
    Guid Id,
    Guid LevelId,
    string Text,
    string? Phonetic,
    string? AudioKey,
    int SortOrder,
    IReadOnlyCollection<string> Tags);
