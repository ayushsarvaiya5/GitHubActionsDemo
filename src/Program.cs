using System.Diagnostics;
using GitHubActionsDemo.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<OrderService>();

var app = builder.Build();

app.MapGet("/", () => "GitHub Actions Demo API");

app.MapGet("/api/order/calculate-total", (decimal price, int quantity, decimal discountPercent) =>
{
    var orderService = app.Services.GetRequiredService<OrderService>();

    var result = orderService.CalculateTotal(
        price,
        quantity,
        discountPercent);

    return Results.Ok(result);

});

app.MapGet("/api/order/calculate-total-with-tax", (decimal price, int quantity, decimal discountPercent, decimal taxPercent) =>
{
    var orderService = app.Services.GetRequiredService<OrderService>();

    var result = orderService.CalculateTotalWithTax(
        price,
        quantity,
        discountPercent,
        taxPercent);

    return Results.Ok(result);
});

app.MapGet("/api/say-hello", () =>
{
    var result = "Hello, World!";

    return Results.Ok(result);
});

// Failing case for CodeQL analysis
app.MapGet("/api/search", (string name) =>
{
    var sql_query = $"SELECT * FROM Users WHERE Name = '{name}'";

    // This is a vulnerable code that can lead to SQL injection
    // In a real application, you should use parameterized queries to prevent SQL injection attacks

    return Results.Ok($"Executing query: {sql_query}");
});

// CodeQL demonstration: intentionally vulnerable code
app.MapGet("/api/file", (string fileName) =>
{
    // BAD: User-controlled input is directly used as a file path.
    var content = File.ReadAllText(fileName);

    return Results.Ok(content);
});

// Command Injection
app.MapGet("/api/ping", (string host) =>
{
    var process = new Process
    {
        StartInfo = new ProcessStartInfo
        {
            FileName = "ping",
            Arguments = host,
            RedirectStandardOutput = true,
            UseShellExecute = false
        }
    };

    process.Start();

    var output = process.StandardOutput.ReadToEnd();

    return Results.Ok(output);
});

app.Run();
