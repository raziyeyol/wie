using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace wieApi.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RemoveWordTags : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Tags",
                table: "Words");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Tags",
                table: "Words",
                type: "TEXT",
                nullable: false,
                defaultValue: "");
        }
    }
}
