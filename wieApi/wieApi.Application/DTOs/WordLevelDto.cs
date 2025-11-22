namespace wieApi.Application.DTOs;

public record WordLevelDto(
    Guid Id,
    string Name,
    string YearBand,
    string Difficulty,
    string Description,
    int WordCount);
