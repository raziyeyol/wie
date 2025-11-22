using System.Collections.Generic;

namespace wieApi.Domain.Entities;

public class WordLevel
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string YearBand { get; set; } = string.Empty;
    public string Difficulty { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public ICollection<Word> Words { get; set; } = new List<Word>();
}
