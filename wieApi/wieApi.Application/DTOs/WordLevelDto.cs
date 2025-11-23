namespace wieApi.Application.DTOs;

public record WordLevelDto(
    Guid Id,
    string Name,
    string Description,
    int WordCount);
