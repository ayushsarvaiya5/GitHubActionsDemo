namespace GitHubActionsDemo.Services;

public class OrderService
{
    private const decimal TaxRate = 0.18m;

    public OrderCalculation CalculateTotal(
        decimal price,
        int quantity,
        decimal discountPercent)
    {
        if (price < 0)
            throw new ArgumentException("Price cannot be negative.");

        if (quantity <= 0)
            throw new ArgumentException("Quantity must be greater than zero.");

        if (discountPercent < 0 || discountPercent > 100)
            throw new ArgumentException(
                "Discount must be between 0 and 100 percent.");

        var subtotal = price * quantity;

        var discountAmount = subtotal * (discountPercent / 100);

        var amountAfterDiscount = subtotal - discountAmount;

        var taxAmount = amountAfterDiscount * TaxRate;

        var total = amountAfterDiscount + taxAmount;

        return new OrderCalculation(
            Subtotal: subtotal,
            Discount: discountAmount,
            Tax: taxAmount,
            Total: total);
    }

    public OrderCalculation CalculateTotalWithTax(
        decimal price,
        int quantity,
        decimal discountPercent,
        decimal taxPercent)
    {
        if (price < 0)
            throw new ArgumentException("Price cannot be negative.");

        if (quantity <= 0)
            throw new ArgumentException("Quantity must be greater than zero.");

        if (discountPercent < 0 || discountPercent > 100)
            throw new ArgumentException(
                "Discount must be between 0 and 100 percent.");

        if (taxPercent < 0 || taxPercent > 100)
            throw new ArgumentException(
                "Tax must be between 0 and 100 percent.");

        var subtotal = price * quantity;

        var discountAmount = subtotal * (discountPercent / 100);

        var amountAfterDiscount = subtotal - discountAmount;

        var taxAmount = amountAfterDiscount * (taxPercent / 100);

        var total = amountAfterDiscount + taxAmount;

        return new OrderCalculation(
            Subtotal: subtotal,
            Discount: discountAmount,
            Tax: taxAmount,
            Total: total);
    }
}

public record OrderCalculation(
decimal Subtotal,
decimal Discount,
decimal Tax,
decimal Total);
