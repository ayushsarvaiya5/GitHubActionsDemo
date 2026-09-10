var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () => "Hello from GitHub Actions!");

app.MapGet("/api/hello", () =>
{
    return new
    {
        Message = "Hello World",
        Service = "GitHubActionsDemo"
    };
});

app.Run();