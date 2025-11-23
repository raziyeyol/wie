namespace wieApi.Domain.Entities;

public class Word
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid WordLevelId { get; set; }
    public string Text { get; set; } = string.Empty;
    public string? AudioKey { get; set; }
    public int SortOrder { get; set; }

    public WordLevel? Level { get; set; }
}
