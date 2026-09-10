using GitHubActionsDemo.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<OrderService>();

var app = builder.Build();

app.MapGet("/", () => "GitHub Actions Demo API");

app.MapGet("/api/order/total", (decimal price, int quantity, decimal discountPercent) =>
{
    var orderService = app.Services.GetRequiredService<OrderService>();

    var result = orderService.CalculateTotal(
        price,
        quantity,
        discountPercent);

    return Results.Ok(result);

});

app.Run();
