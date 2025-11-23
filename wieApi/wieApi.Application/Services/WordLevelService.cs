using wieApi.Application.DTOs;
using wieApi.Application.Interfaces;

namespace wieApi.Application.Services;

//business logic for word levels
public class WordLevelService : IWordLevelService
{
    private readonly IWordLevelRepository _repository;

    public WordLevelService(
        IWordLevelRepository repository)
    {
        _repository = repository;
    }

    public async Task<IReadOnlyCollection<WordLevelDto>> GetWordLevelsAsync(CancellationToken cancellationToken = default)
    {
        var levels = await _repository.GetAllAsync(cancellationToken);
        return levels
            .Select(level => new WordLevelDto(
                level.Id,
                level.Name,
                level.Description,
                level.Words.Count))
            .ToList();
    }

    public async Task<WordLevelDto?> GetWordLevelAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var level = await _repository.GetByIdAsync(id, cancellationToken);
        return level is null
            ? null
            : new WordLevelDto(level.Id, level.Name, level.Description, level.Words.Count);
    }

    public async Task<IReadOnlyCollection<WordDto>> GetWordsForLevelAsync(Guid levelId, CancellationToken cancellationToken = default)
    {
        var words = await _repository.GetWordsForLevelAsync(levelId, cancellationToken);
        return words
            .Select(word => new WordDto(
                word.Id,
                word.WordLevelId,
                word.Text,
                word.AudioKey,
                word.SortOrder))
            .ToList();
    }

    public async Task<IReadOnlyCollection<WordLevelWithWordsDto>> GetWordLevelsWithWordsAsync(CancellationToken cancellationToken = default)
    {
        var levels = await _repository.GetAllAsync(cancellationToken);
        return levels
            .Select(level => new WordLevelWithWordsDto(
                level.Id,
                level.Name,
                level.Description,
                level.Words
                    .OrderBy(word => word.SortOrder)
                    .ThenBy(word => word.Text)
                    .Select(word => new WordDto(
                        word.Id,
                        word.WordLevelId,
                        word.Text,
                        word.AudioKey,
                        word.SortOrder))
                    .ToList()))
            .ToList();
    }

}
