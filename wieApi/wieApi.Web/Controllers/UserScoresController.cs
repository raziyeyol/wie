using Microsoft.AspNetCore.Mvc;
using wieApi.Application.DTOs;
using wieApi.Application.Interfaces;

namespace wieApi.Web.Controllers;

[ApiController]
[Route("api/users/{userId:guid}/scores")]
public class UserScoresController : ControllerBase
{
    private readonly IPlayerDataService _playerDataService;

    public UserScoresController(IPlayerDataService playerDataService)
    {
        _playerDataService = playerDataService;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyCollection<ScoreDto>>> Get(Guid userId, [FromQuery] string? gameMode, CancellationToken cancellationToken)
    {
        var scores = await _playerDataService.GetScoresAsync(userId, gameMode, cancellationToken);
        return Ok(scores);
    }

    [HttpPost]
    public async Task<ActionResult<ScoreDto>> Post(Guid userId, [FromBody] CreateScoreRequest request, CancellationToken cancellationToken)
    {
        if (userId != request.UserId)
        {
            return BadRequest("Route userId does not match payload userId.");
        }

        var score = await _playerDataService.AddScoreAsync(request, cancellationToken);
        return Ok(score);
    }
}
