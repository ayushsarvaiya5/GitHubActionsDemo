namespace GitHubActionsDemo.Tests;

public class CalculatorTests
{
    [Fact]
    public void Add_TwoNumbers_ReturnsCorrectResult()
    {
        var result = 10 + 20;

        Assert.Equal(20, result);
    }
}