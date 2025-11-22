using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace wieApi.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RemovePhoneticFromWord : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Phonetic",
                table: "Words");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Phonetic",
                table: "Words",
                type: "TEXT",
                nullable: true);
        }
    }
}
