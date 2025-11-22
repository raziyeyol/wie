namespace wieApi.Domain.Entities;

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string DisplayName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public ICollection<Score> Scores { get; set; } = new List<Score>();
    public ICollection<UserProgressSnapshot> ProgressSnapshots { get; set; } = new List<UserProgressSnapshot>();
}
