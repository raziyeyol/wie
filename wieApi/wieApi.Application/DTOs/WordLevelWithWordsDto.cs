namespace wieApi.Application.DTOs;

public record WordLevelWithWordsDto(
    Guid Id,
    string Name,
    string YearBand,
    string Difficulty,
    string Description,
    IReadOnlyCollection<WordDto> Words);
