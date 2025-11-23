using Microsoft.AspNetCore.Mvc;
using wieApi.Application.DTOs;
using wieApi.Application.Interfaces;

namespace wieApi.Web.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WordLevelsController : ControllerBase
{
    private readonly IWordLevelService _wordLevelService;

    public WordLevelsController(IWordLevelService wordLevelService)
    {
        _wordLevelService = wordLevelService;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyCollection<WordLevelDto>>> GetLevels(CancellationToken cancellationToken)
    {
        var levels = await _wordLevelService.GetWordLevelsAsync(cancellationToken);
        return Ok(levels);
    }

    [HttpGet("with-words")]
    public async Task<ActionResult<IReadOnlyCollection<WordLevelWithWordsDto>>> GetLevelsWithWords(CancellationToken cancellationToken)
    {
        var levels = await _wordLevelService.GetWordLevelsWithWordsAsync(cancellationToken);
        return Ok(levels);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<WordLevelDto>> GetLevel(Guid id, CancellationToken cancellationToken)
    {
        var level = await _wordLevelService.GetWordLevelAsync(id, cancellationToken);
        return level is null ? NotFound() : Ok(level);
    }

    [HttpGet("{id:guid}/words")]
    public async Task<ActionResult<IReadOnlyCollection<WordDto>>> GetWords(Guid id, CancellationToken cancellationToken)
    {
        var words = await _wordLevelService.GetWordsForLevelAsync(id, cancellationToken);
        return words.Count == 0 ? NotFound() : Ok(words);
    }

}
