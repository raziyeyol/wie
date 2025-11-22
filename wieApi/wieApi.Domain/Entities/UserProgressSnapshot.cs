namespace wieApi.Domain.Entities;

public class UserProgressSnapshot
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public int TotalStars { get; set; }
    public int TotalPoints { get; set; }
    public int WordsPracticed { get; set; }
    public string BadgesCsv { get; set; } = string.Empty;
    public DateTime CapturedAtUtc { get; set; } = DateTime.UtcNow;

    public User? User { get; set; }
}
