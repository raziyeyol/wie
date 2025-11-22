namespace wieApi.Application.DTOs;

public record CreateUserRequest(
    string DisplayName,
    string? AvatarUrl);
