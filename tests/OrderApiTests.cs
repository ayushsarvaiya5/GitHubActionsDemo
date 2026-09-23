using System.Net;
using System.Net.Http.Json;
using GitHubActionsDemo.Services;
using Microsoft.AspNetCore.Mvc.Testing;

namespace GitHubActionsDemo.Tests;

public class OrderApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public OrderApiTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task GetTotal_ReturnsOrderTotals()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync("/api/order/total?price=100&quantity=2&discountPercent=10");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var result = await response.Content.ReadFromJsonAsync<OrderCalculation>();

        Assert.NotNull(result);
        Assert.Equal(200m, result!.Subtotal);
        Assert.Equal(20m, result.Discount);
        Assert.Equal(32.40m, result.Tax);
        Assert.Equal(212.40m, result.Total);
    }

    [Fact]
    public async Task GetTotalWithTax_ReturnsOrderTotalsUsingCustomTaxRate()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync("/api/order/total-with-tax?price=100&quantity=2&discountPercent=10&taxPercent=15");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var result = await response.Content.ReadFromJsonAsync<OrderCalculation>();

        Assert.NotNull(result);
        Assert.Equal(200m, result!.Subtotal);
        Assert.Equal(20m, result.Discount);
        Assert.Equal(27m, result.Tax);
        Assert.Equal(207m, result.Total);
    }
}
