using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace wieApi.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RemoveYearBandAndDifficultyFromWordLevels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Difficulty",
                table: "WordLevels");

            migrationBuilder.DropColumn(
                name: "YearBand",
                table: "WordLevels");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Difficulty",
                table: "WordLevels",
                type: "TEXT",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "YearBand",
                table: "WordLevels",
                type: "TEXT",
                maxLength: 50,
                nullable: false,
                defaultValue: "");
        }
    }
}
