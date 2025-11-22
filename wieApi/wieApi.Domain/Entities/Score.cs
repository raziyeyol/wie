namespace wieApi.Domain.Entities;

public class Score
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string GameMode { get; set; } = string.Empty;
    public int Points { get; set; }
    public int Stars { get; set; }
    public TimeSpan Duration { get; set; }
    public DateTime CompletedAtUtc { get; set; } = DateTime.UtcNow;
    public string? MetadataJson { get; set; }

    public User? User { get; set; }
}
