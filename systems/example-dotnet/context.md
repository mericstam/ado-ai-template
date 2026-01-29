# Example .NET System

## Stack

- **Language:** C# 12
- **Framework:** .NET 8
- **Build Tool:** dotnet CLI
- **Cloud:** Azure

## Architecture

<!-- TODO: Fill in project-specific architecture -->

Clean Architecture with CQRS:

- **Domain:** Entities, value objects, domain events
- **Application:** Commands/Queries with MediatR
- **Infrastructure:** EF Core, Azure SDK integrations
- **WebApi:** Controllers, middleware

## Conventions

- Async all the way (never .Result or .Wait())
- Constructor injection via built-in DI
- IOptions<T> pattern for configuration
- Nullable reference types enabled

## Azure Services

<!-- TODO: Specify which Azure services are used -->

- Azure App Service / Container Apps
- Azure SQL / Cosmos DB
- Azure Service Bus
- Azure Key Vault

## Testing

- xUnit with FluentAssertions
- NSubstitute for mocking
- Testcontainers for integration tests

## Error Handling

- ProblemDetails for API errors (RFC 7807)
- Structured logging with Serilog
