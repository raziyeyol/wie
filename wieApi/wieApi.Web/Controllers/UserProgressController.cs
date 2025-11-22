using Microsoft.AspNetCore.Mvc;
using wieApi.Application.DTOs;
using wieApi.Application.Interfaces;

namespace wieApi.Web.Controllers;

[ApiController]
[Route("api/users/{userId:guid}/progress")]
public class UserProgressController : ControllerBase
{
    private readonly IPlayerDataService _playerDataService;

    public UserProgressController(IPlayerDataService playerDataService)
    {
        _playerDataService = playerDataService;
    }

    [HttpGet]
    public async Task<ActionResult<ProgressSnapshotDto>> Get(Guid userId, CancellationToken cancellationToken)
    {
        var snapshot = await _playerDataService.GetLatestProgressAsync(userId, cancellationToken);
        return snapshot is null ? NotFound() : Ok(snapshot);
    }

    [HttpPost]
    public async Task<ActionResult<ProgressSnapshotDto>> Post(Guid userId, [FromBody] UpsertProgressRequest request, CancellationToken cancellationToken)
    {
        if (userId != request.UserId)
        {
            return BadRequest("Route userId does not match payload userId.");
        }

        var snapshot = await _playerDataService.UpsertProgressAsync(request, cancellationToken);
        return Ok(snapshot);
    }
}
