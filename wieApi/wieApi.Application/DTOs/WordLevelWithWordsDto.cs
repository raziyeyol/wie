namespace wieApi.Application.DTOs;

public record WordLevelWithWordsDto(
    Guid Id,
    string Name,
    string Description,
    IReadOnlyCollection<WordDto> Words);
