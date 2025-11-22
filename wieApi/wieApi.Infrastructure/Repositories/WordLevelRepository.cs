using Microsoft.EntityFrameworkCore;
using wieApi.Application.Interfaces;
using wieApi.Domain.Entities;
using wieApi.Infrastructure.Persistence;

namespace wieApi.Infrastructure.Repositories;

public class WordLevelRepository : IWordLevelRepository
{
    private readonly WordsLearningDbContext _dbContext;

    public WordLevelRepository(WordsLearningDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public Task<List<WordLevel>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return _dbContext.WordLevels
            .Include(level => level.Words)
            .AsNoTracking()
            .OrderBy(level => level.Name)
            .ToListAsync(cancellationToken);
    }

    public Task<WordLevel?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return _dbContext.WordLevels
            .Include(level => level.Words)
            .AsNoTracking()
            .FirstOrDefaultAsync(level => level.Id == id, cancellationToken);
    }

    public Task<List<Word>> GetWordsForLevelAsync(Guid levelId, CancellationToken cancellationToken = default)
    {
        return _dbContext.Words
            .Where(word => word.WordLevelId == levelId)
            .AsNoTracking()
            .OrderBy(word => word.SortOrder)
            .ThenBy(word => word.Text)
            .ToListAsync(cancellationToken);
    }

    public Task AddAsync(WordLevel level, CancellationToken cancellationToken = default)
    {
        return _dbContext.WordLevels.AddAsync(level, cancellationToken).AsTask();
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return _dbContext.SaveChangesAsync(cancellationToken);
    }
}
