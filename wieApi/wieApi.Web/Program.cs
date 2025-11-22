using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using wieApi.Application;
using wieApi.Infrastructure;
using wieApi.Infrastructure.Persistence;
using wieApi.Infrastructure.Seed;
using wieApi.Web.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Logging.AddConsole();

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddControllers();
builder.Services.AddProblemDetails();
builder.Services.Configure<ApiBehaviorOptions>(options =>
{
    options.SuppressModelStateInvalidFilter = true;
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<WordsLearningDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("Seeder");
    await dbContext.Database.MigrateAsync();
    await DataSeeder.SeedAsync(dbContext, logger);
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseGlobalExceptionHandling();


// Skip HTTPS redirection so we can run on plain HTTP when no dev certificate is configured.
// In production this should be re-enabled behind a proper TLS endpoint.
if (app.Environment.IsProduction())
{
    app.UseHttpsRedirection();
}

app.MapControllers();

app.Run();
