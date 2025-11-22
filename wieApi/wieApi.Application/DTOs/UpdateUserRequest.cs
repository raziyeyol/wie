namespace wieApi.Application.DTOs;

public record UpdateUserRequest(
    string DisplayName,
    string? AvatarUrl);
