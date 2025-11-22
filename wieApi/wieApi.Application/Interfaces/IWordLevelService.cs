using wieApi.Application.DTOs;

namespace wieApi.Application.Interfaces;

public interface IWordLevelService
{
    Task<IReadOnlyCollection<WordLevelDto>> GetWordLevelsAsync(CancellationToken cancellationToken = default);
    Task<WordLevelDto?> GetWordLevelAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyCollection<WordDto>> GetWordsForLevelAsync(Guid levelId, CancellationToken cancellationToken = default);
    Task<IReadOnlyCollection<WordLevelWithWordsDto>> GetWordLevelsWithWordsAsync(CancellationToken cancellationToken = default);
    Task<Guid> CreateWordLevelAsync(CreateWordLevelRequest request, CancellationToken cancellationToken = default);
}
