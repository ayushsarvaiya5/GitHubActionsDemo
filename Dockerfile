# syntax=docker/dockerfile:1.7

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

COPY src/GitHubActionsDemo.csproj src/
RUN dotnet restore src/GitHubActionsDemo.csproj

COPY src/ src/

RUN dotnet publish src/GitHubActionsDemo.csproj \
    -c Release \
    -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 8080

ENTRYPOINT ["dotnet", "GitHubActionsDemo.dll"]