using wieApi.Domain.Entities;

namespace wieApi.Application.Interfaces;

public interface IWordLevelRepository
{
    Task<List<WordLevel>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<WordLevel?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<List<Word>> GetWordsForLevelAsync(Guid levelId, CancellationToken cancellationToken = default);
    Task AddAsync(WordLevel level, CancellationToken cancellationToken = default);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
