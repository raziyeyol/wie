namespace wieApi.Application.DTOs;

public record CreateWordLevelRequest(
    string Name,
    string YearBand,
    string Difficulty,
    string Description,
    IReadOnlyCollection<string> Words);
