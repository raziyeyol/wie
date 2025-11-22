using FluentValidation;
using Microsoft.Extensions.Logging;
using wieApi.Application.DTOs;
using wieApi.Application.Interfaces;
using wieApi.Domain.Entities;

namespace wieApi.Application.Services;

public class WordLevelService : IWordLevelService
{
    private readonly IWordLevelRepository _repository;
    private readonly IValidator<CreateWordLevelRequest> _validator;
    private readonly ILogger<WordLevelService> _logger;

    public WordLevelService(
        IWordLevelRepository repository,
        IValidator<CreateWordLevelRequest> validator,
        ILogger<WordLevelService> logger)
    {
        _repository = repository;
        _validator = validator;
        _logger = logger;
    }

    public async Task<IReadOnlyCollection<WordLevelDto>> GetWordLevelsAsync(CancellationToken cancellationToken = default)
    {
        var levels = await _repository.GetAllAsync(cancellationToken);
        return levels
            .Select(level => new WordLevelDto(
                level.Id,
                level.Name,
                level.YearBand,
                level.Difficulty,
                level.Description,
                level.Words.Count))
            .ToList();
    }

    public async Task<WordLevelDto?> GetWordLevelAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var level = await _repository.GetByIdAsync(id, cancellationToken);
        return level is null
            ? null
            : new WordLevelDto(level.Id, level.Name, level.YearBand, level.Difficulty, level.Description, level.Words.Count);
    }

    public async Task<IReadOnlyCollection<WordDto>> GetWordsForLevelAsync(Guid levelId, CancellationToken cancellationToken = default)
    {
        var words = await _repository.GetWordsForLevelAsync(levelId, cancellationToken);
        return words
            .Select(word => new WordDto(
                word.Id,
                word.WordLevelId,
                word.Text,
                word.Phonetic,
                word.AudioKey,
                word.SortOrder,
                word.Tags))
            .ToList();
    }

    public async Task<IReadOnlyCollection<WordLevelWithWordsDto>> GetWordLevelsWithWordsAsync(CancellationToken cancellationToken = default)
    {
        var levels = await _repository.GetAllAsync(cancellationToken);
        return levels
            .Select(level => new WordLevelWithWordsDto(
                level.Id,
                level.Name,
                level.YearBand,
                level.Difficulty,
                level.Description,
                level.Words
                    .OrderBy(word => word.SortOrder)
                    .ThenBy(word => word.Text)
                    .Select(word => new WordDto(
                        word.Id,
                        word.WordLevelId,
                        word.Text,
                        word.Phonetic,
                        word.AudioKey,
                        word.SortOrder,
                        word.Tags))
                    .ToList()))
            .ToList();
    }

    public async Task<Guid> CreateWordLevelAsync(CreateWordLevelRequest request, CancellationToken cancellationToken = default)
    {
        await _validator.ValidateAndThrowAsync(request, cancellationToken);

        var level = new WordLevel
        {
            Name = request.Name,
            YearBand = request.YearBand,
            Difficulty = request.Difficulty,
            Description = request.Description,
            Words = request.Words
                .Select((word, index) => new Word
                {
                    Text = word,
                    SortOrder = index + 1,
                    Tags = new[] { request.Difficulty }
                })
                .ToList()
        };

        await _repository.AddAsync(level, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Created word level {LevelName} with {WordCount} words", level.Name, level.Words.Count);
        return level.Id;
    }
}
