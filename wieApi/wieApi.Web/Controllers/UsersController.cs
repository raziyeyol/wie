using Microsoft.AspNetCore.Mvc;
using wieApi.Application.DTOs;
using wieApi.Application.Interfaces;

namespace wieApi.Web.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly IPlayerDataService _playerDataService;

    public UsersController(IPlayerDataService playerDataService)
    {
        _playerDataService = playerDataService;
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<UserProfileDto>> Get(Guid id, CancellationToken cancellationToken)
    {
        var user = await _playerDataService.GetUserAsync(id, cancellationToken);
        return user is null ? NotFound() : Ok(user);
    }

    [HttpPost]
    public async Task<ActionResult<UserProfileDto>> Post([FromBody] CreateUserRequest request, CancellationToken cancellationToken)
    {
        var user = await _playerDataService.CreateUserAsync(request, cancellationToken);
        return CreatedAtAction(nameof(Get), new { id = user.Id }, user);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<UserProfileDto>> Put(Guid id, [FromBody] UpdateUserRequest request, CancellationToken cancellationToken)
    {
        var user = await _playerDataService.UpdateUserAsync(id, request, cancellationToken);
        return user is null ? NotFound() : Ok(user);
    }
}
