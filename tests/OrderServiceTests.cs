using GitHubActionsDemo.Services;

namespace GitHubActionsDemo.Tests;

public class OrderServiceTests
{
    private readonly OrderService _orderService = new();

    [Fact]
    public void CalculateTotal_WithNoDiscount_ReturnsSubtotalPlusTax()
    {
        var price = 100m;
        var quantity = 2;
        var discount = 0m;

        var result = _orderService.CalculateTotal(price, quantity, discount);

        Assert.Equal(200m, result.Subtotal);
        Assert.Equal(0m, result.Discount);
        Assert.Equal(36m, result.Tax);
        Assert.Equal(236m, result.Total);
    }

    [Fact]
    public void CalculateTotal_WithDiscount_AppliesDiscountBeforeTax()
    {
        var price = 100m;
        var quantity = 2;
        var discount = 10m;

        var result = _orderService.CalculateTotal(price, quantity, discount);

        Assert.Equal(200m, result.Subtotal);
        Assert.Equal(20m, result.Discount);
        Assert.Equal(32.40m, result.Tax);
        Assert.Equal(212.40m, result.Total);
    }

    [Fact]
    public void CalculateTotalWithTax_WithNoDiscount_UsesProvidedTaxRate()
    {
        var price = 100m;
        var quantity = 2;
        var discount = 0m;
        var taxPercent = 10m;

        var result = _orderService.CalculateTotalWithTax(price, quantity, discount, taxPercent);

        Assert.Equal(200m, result.Subtotal);
        Assert.Equal(0m, result.Discount);
        Assert.Equal(20m, result.Tax);
        Assert.Equal(220m, result.Total);
    }

    [Fact]
    public void CalculateTotalWithTax_WithDiscount_AppliesDiscountBeforeCustomTax()
    {
        var price = 100m;
        var quantity = 2;
        var discount = 10m;
        var taxPercent = 15m;

        var result = _orderService.CalculateTotalWithTax(price, quantity, discount, taxPercent);

        Assert.Equal(200m, result.Subtotal);
        Assert.Equal(20m, result.Discount);
        Assert.Equal(27m, result.Tax);
        Assert.Equal(207m, result.Total);
    }

    [Fact]
    public void CalculateTotal_WithZeroQuantity_ThrowsException()
    {
        var exception = Assert.Throws<ArgumentException>(() =>
            _orderService.CalculateTotal(100m, 0, 10m));

        Assert.Equal("Quantity must be greater than zero.", exception.Message);
    }

    [Fact]
    public void CalculateTotal_WithNegativePrice_ThrowsException()
    {
        var exception = Assert.Throws<ArgumentException>(() =>
            _orderService.CalculateTotal(-100m, 2, 10m));

        Assert.Equal("Price cannot be negative.", exception.Message);
    }

    [Fact]
    public void CalculateTotal_WithInvalidDiscount_ThrowsException()
    {
        var exception = Assert.Throws<ArgumentException>(() =>
            _orderService.CalculateTotal(100m, 2, 110m));

        Assert.Equal("Discount must be between 0 and 100 percent.", exception.Message);
    }

    [Fact]
    public void CalculateTotalWithTax_WithInvalidTax_ThrowsException()
    {
        var exception = Assert.Throws<ArgumentException>(() =>
            _orderService.CalculateTotalWithTax(100m, 2, 10m, 110m));

        Assert.Equal("Tax must be between 0 and 100 percent.", exception.Message);
    }
}
