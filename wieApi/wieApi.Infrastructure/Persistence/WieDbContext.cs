using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using wieApi.Domain.Entities;

namespace wieApi.Infrastructure.Persistence;

public class WieDbContext : DbContext
{
    public WieDbContext(DbContextOptions<WieDbContext> options) : base(options)
    {
    }

    public DbSet<WordLevel> WordLevels => Set<WordLevel>();
    public DbSet<Word> Words => Set<Word>();
    public DbSet<User> Users => Set<User>();
    public DbSet<UserProgressSnapshot> ProgressSnapshots => Set<UserProgressSnapshot>();
    public DbSet<Score> Scores => Set<Score>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<WordLevel>(builder =>
        {
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Name).HasMaxLength(100);
            builder.Property(x => x.YearBand).HasMaxLength(50);
            builder.Property(x => x.Difficulty).HasMaxLength(50);
            builder.Property(x => x.Description).HasMaxLength(500);

            builder.HasMany(x => x.Words)
                .WithOne(x => x.Level)
                .HasForeignKey(x => x.WordLevelId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        var stringArrayComparer = new ValueComparer<string[]>(
            (left, right) => left!.SequenceEqual(right!),
            value => value.Aggregate(0, (hash, item) => HashCode.Combine(hash, item.GetHashCode(StringComparison.OrdinalIgnoreCase))),
            value => value.ToArray());

        modelBuilder.Entity<Word>(builder =>
        {
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Text).HasMaxLength(100).IsRequired();
            builder.Property(x => x.SortOrder).HasDefaultValue(0);
            builder.Property(x => x.Tags)
                .HasConversion(
                    v => string.Join(';', v ?? Array.Empty<string>()),
                    v => string.IsNullOrWhiteSpace(v)
                        ? Array.Empty<string>()
                        : v.Split(';', StringSplitOptions.RemoveEmptyEntries))
                .Metadata.SetValueComparer(stringArrayComparer);
        });

        modelBuilder.Entity<User>(builder =>
        {
            builder.HasKey(x => x.Id);
            builder.Property(x => x.DisplayName).HasMaxLength(80).IsRequired();
            builder.Property(x => x.AvatarUrl).HasMaxLength(256);
            builder.Property(x => x.CreatedAtUtc).IsRequired();
        });

        modelBuilder.Entity<UserProgressSnapshot>(builder =>
        {
            builder.HasKey(x => x.Id);
            builder.Property(x => x.BadgesCsv).HasMaxLength(256);
            builder.Property(x => x.CapturedAtUtc).IsRequired();

            builder.HasOne(x => x.User)
                .WithMany(x => x.ProgressSnapshots)
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Score>(builder =>
        {
            builder.HasKey(x => x.Id);
            builder.Property(x => x.GameMode).HasMaxLength(80).IsRequired();
            builder.Property(x => x.MetadataJson).HasMaxLength(4000);
            builder.Property(x => x.CompletedAtUtc).IsRequired();

            builder.HasOne(x => x.User)
                .WithMany(x => x.Scores)
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
