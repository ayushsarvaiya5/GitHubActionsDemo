using GitHubActionsDemo.Services;

namespace GitHubActionsDemo.Tests;

public class OrderServiceTests
{
    private readonly OrderService _orderService = new();

    [Fact]
    public void CalculateTotal_WithNoDiscount_ReturnsSubtotalPlusTax()
    {
        // Arrange
        var price = 100m;
        var quantity = 2;
        var discount = 0m;

        // Act
        var result = _orderService.CalculateTotal(
            price,
            quantity,
            discount);

        // Assert
        Assert.Equal(200m, result.Subtotal);
        Assert.Equal(0m, result.Discount);
        Assert.Equal(36m, result.Tax);
        Assert.Equal(236m, result.Total);
    }

    [Fact]
    public void CalculateTotal_WithDiscount_AppliesDiscountBeforeTax()
    {
        // Arrange
        var price = 100m;
        var quantity = 2;
        var discount = 10m;

        // Act
        var result = _orderService.CalculateTotal(
            price,
            quantity,
            discount);

        // Assert
        Assert.Equal(200m, result.Subtotal);
        Assert.Equal(20m, result.Discount);
        Assert.Equal(32.40m, result.Tax);
        Assert.Equal(212.40m, result.Total);
    }

    [Fact]
    public void CalculateTotal_WithZeroQuantity_ThrowsException()
    {
        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() =>
            _orderService.CalculateTotal(
                100m,
                0,
                10m));

        Assert.Equal(
            "Quantity must be greater than zero.",
            exception.Message);
    }

    [Fact]
    public void CalculateTotal_WithNegativePrice_ThrowsException()
    {
        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() =>
            _orderService.CalculateTotal(
                -100m,
                2,
                10m));

        Assert.Equal(
            "Price cannot be negative.",
            exception.Message);
    }

    [Fact]
    public void CalculateTotal_WithInvalidDiscount_ThrowsException()
    {
        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() =>
            _orderService.CalculateTotal(
                100m,
                2,
                110m));

        Assert.Equal(
            "Discount must be between 0 and 100 percent.",
            exception.Message);
    }

}
