
---

## Aspire Integration — Full Adoption

This is an Aspire-native application. Aspire is not an afterthought — it's the orchestration layer for local development.

### AppHost

```csharp
// RiskDataPlatform.AppHost/Program.cs should wire up:

var builder = DistributedApplication.CreateBuilder(args);

// SQL Server for Orleans grain state
var sqlServer = builder.AddSqlServer("sql")
    .AddDatabase("orleans-storage");

// Orleans cluster (co-hosted with API)
var api = builder.AddProject<Projects.RiskDataPlatform_Api>("risk-api")
    .WithReference(sqlServer)
    .WaitFor(sqlServer);

builder.Build().Run();
```

### ServiceDefaults

The ServiceDefaults project must configure:
- OpenTelemetry (tracing + metrics + logging)
- Health checks
- Service discovery
- Resilience (Polly-based retry/circuit breaker for S3 calls)

```csharp
// RiskDataPlatform.ServiceDefaults/Extensions.cs should include:
public static IHostApplicationBuilder AddServiceDefaults(this IHostApplicationBuilder builder)
{
    builder.ConfigureOpenTelemetry();
    builder.AddDefaultHealthChecks();
    // ... resilience, service discovery
}

public static IHostApplicationBuilder ConfigureOpenTelemetry(this IHostApplicationBuilder builder)
{
    builder.Logging.AddOpenTelemetry(logging =>
    {
        logging.IncludeFormattedMessage = true;
        logging.IncludeScopes = true;
    });

    builder.Services.AddOpenTelemetry()
        .WithMetrics(metrics =>
        {
            metrics.AddAspNetCoreInstrumentation()
                   .AddHttpClientInstrumentation()
                   .AddRuntimeInstrumentation();
        })
        .WithTracing(tracing =>
        {
            tracing.AddAspNetCoreInstrumentation()
                   .AddHttpClientInstrumentation()
                   .AddSource("Microsoft.Orleans.Runtime")
                   .AddSource("Microsoft.Orleans.Application")
                   .AddSource("RiskDataPlatform.Api")
                   .AddSource("RiskDataPlatform.Grains")
                   .AddSource("RiskDataPlatform.Query")
                   .AddSource("RiskDataPlatform.Arrow");
        });

    // For local dev: use Aspire dashboard as the OTLP endpoint
    builder.Services.AddOpenTelemetry()
        .UseOtlpExporter();

    return builder;
}
```

### Aspire Dashboard
When running via Aspire AppHost, the Aspire dashboard is automatically available showing:
- Structured logs from all components
- Distributed traces for every request
- Metrics (request rate, latency, error rate)
- Resource health (SQL Server, API)

---

## Structured Logging — Key Flow Points

Every significant operation must have structured log entries with consistent properties. Use `ILogger<T>` with semantic logging (NOT string interpolation).

### ActivitySource for Custom Traces

Create ActivitySources for each layer:

```csharp
// RiskDataPlatform.Core/Diagnostics/Telemetry.cs
public static class Telemetry
{
    public static readonly ActivitySource ApiSource = new("RiskDataPlatform.Api");
    public static readonly ActivitySource GrainSource = new("RiskDataPlatform.Grains");
    public static readonly ActivitySource QuerySource = new("RiskDataPlatform.Query");
    public static readonly ActivitySource ArrowSource = new("RiskDataPlatform.Arrow");
    public static readonly ActivitySource StorageSource = new("RiskDataPlatform.Storage");
}
```

### Required Log Points and Trace Spans

#### API Layer (every endpoint)

```csharp
// Every endpoint must log:
// 1. Request received (Information)
_logger.LogInformation(
    "Query request received. ExecutionIds={ExecutionIds} Tenant={TenantId} Format={Format} StartRow={StartRow} EndRow={EndRow}",
    request.ExecutionIds, tenantId, request.Format, request.Ssrm.StartRow, request.Ssrm.EndRow);

// 2. Request completed (Information)
_logger.LogInformation(
    "Query completed. ExecutionIds={ExecutionIds} Rows={RowCount} CacheHit={CacheHit} Duration={DurationMs}ms Format={Format}",
    request.ExecutionIds, response.TotalRowCount, response.FromCache, stopwatch.ElapsedMilliseconds, format);

// 3. Every endpoint must create a trace span:
using var activity = Telemetry.ApiSource.StartActivity("QueryExecutionData");
activity?.SetTag("tenant.id", tenantId);
activity?.SetTag("execution.ids", string.Join(",", request.ExecutionIds));
activity?.SetTag("response.format", format.ToString());
```

#### Tenant Middleware

```csharp
_logger.LogDebug(
    "Tenant resolved. TenantId={TenantId} Source={Source}",
    tenantId, source); // source = "header" or "default"
```

#### Request Sanitizer

```csharp
// Log validation failures as warnings
_logger.LogWarning(
    "Request validation failed. Rule={Rule} Detail={Detail} Tenant={TenantId}",
    "DuplicateDeskReportType", $"Desk={deskId} Type={reportType}", tenantId);
```

#### Error Handling Middleware

```csharp
_logger.LogError(ex,
    "Request failed. ErrorCode={ErrorCode} Transient={IsTransient} TraceId={TraceId} Path={Path}",
    error.Code, error.IsTransient, traceId, context.Request.Path);
```

#### Grain Layer

```csharp
// ExecutionGrain
_logger.LogInformation(
    "Execution created. ExecutionId={ExecutionId} ReportType={ReportType} Desks={Desks} Books={BookCount} Trades={TradeCount}",
    execution.ExecutionId, execution.ReportType, execution.DeskIds, execution.ResolvedBooks.Count, tradeCount);

_logger.LogInformation(
    "Execution status changed. ExecutionId={ExecutionId} From={FromStatus} To={ToStatus}",
    executionId, previousStatus, newStatus);

_logger.LogInformation(
    "Execution completed. ExecutionId={ExecutionId} Duration={DurationMs}ms TradeCount={TradeCount} Errors={ErrorCount}",
    executionId, duration.TotalMilliseconds, tradeCount, errorCount);

// ReportDataGrain
using var activity = Telemetry.GrainSource.StartActivity("ReportDataGrain.Query");

_logger.LogInformation(
    "Data loaded into DuckDB. ExecutionId={ExecutionId} Books={BookCount} Trades={TradeCount} Duration={DurationMs}ms",
    executionId, bookCount, tradeCount, stopwatch.ElapsedMilliseconds);

_logger.LogDebug(
    "Query executed. ExecutionId={ExecutionId} CacheHit={CacheHit} DuckDbDuration={DuckDbMs}ms Rows={RowCount}",
    executionId, cacheHit, duckDbDuration.TotalMilliseconds, rowCount);

// ComparisonGrain
_logger.LogInformation(
    "Comparison initialized. ComparisonId={ComparisonId} ExecutionIds={ExecutionIds} ChangedBooks={ChangedBooks} SkippedBooks={SkippedBooks}",
    comparisonId, executionIds, changedCount, skippedCount);

// DeskGrain
_logger.LogInformation(
    "Incremental slot granted. DeskId={DeskId} ExecutionId={ExecutionId} ActiveSlots={ActiveSlots}/{MaxSlots}",
    deskId, executionId, activeCount, maxSlots);

_logger.LogWarning(
    "Incremental slot denied. DeskId={DeskId} ExecutionId={ExecutionId} ActiveSlots={ActiveSlots}/{MaxSlots} ActiveExecutions={ActiveExecutionIds}",
    deskId, executionId, activeCount, maxSlots, activeIds);

// NotificationGrain
_logger.LogInformation(
    "Notification sent. Type={NotificationType} DeskId={DeskId} ExecutionId={ExecutionId} Recipients=desk-group",
    "ExecutionCompleted", deskId, executionId);
```

#### Query Layer (DuckDB)

```csharp
using var activity = Telemetry.QuerySource.StartActivity("DuckDb.ExecuteQuery");
activity?.SetTag("query.sql", sql); // Only in debug/development
activity?.SetTag("query.param_count", parameters.Count);

_logger.LogDebug(
    "DuckDB query. SQL={Sql} Params={ParamCount} Duration={DurationMs}ms Rows={RowCount}",
    sql, parameters.Count, stopwatch.ElapsedMilliseconds, rowCount);
```

#### Arrow / Storage Layer

```csharp
using var activity = Telemetry.ArrowSource.StartActivity("ArrowResultMerger.Merge");

_logger.LogInformation(
    "Arrow merge started. ExecutionId={ExecutionId} GridTasks={TaskCount}",
    executionId, gridResults.Count);

_logger.LogDebug(
    "Book written. ExecutionId={ExecutionId} BookName={BookName} Trades={TradeCount} SizeKB={SizeKB} DictColumns={DictColumnCount}",
    executionId, bookName, tradeCount, sizeBytes / 1024, dictColumnCount);

_logger.LogInformation(
    "Arrow merge completed. ExecutionId={ExecutionId} Books={BookCount} TotalTrades={TradeCount} TotalSizeMB={SizeMB} Duration={DurationMs}ms",
    executionId, bookCount, totalTrades, totalSize / 1024 / 1024, stopwatch.ElapsedMilliseconds);

// S3 operations
using var activity = Telemetry.StorageSource.StartActivity("S3.PutObject");
activity?.SetTag("s3.path", s3Path);
activity?.SetTag("s3.size_bytes", data.Length);

_logger.LogDebug(
    "S3 write. Path={S3Path} SizeKB={SizeKB} Duration={DurationMs}ms",
    s3Path, data.Length / 1024, stopwatch.ElapsedMilliseconds);
```

### Orleans Logging Noise Filtering

Orleans generates excessive logging. Filter it:

```csharp
builder.Logging
    .AddFilter("Orleans.Runtime", LogLevel.Warning)
    .AddFilter("Orleans.Messaging", LogLevel.Warning)
    .AddFilter("Orleans.Networking", LogLevel.Warning)
    .AddFilter("Orleans.Hosting", LogLevel.Warning)
    .AddFilter("Orleans.Runtime.SiloControl", LogLevel.Warning)
    .AddFilter("Orleans.Runtime.Management", LogLevel.Warning)
    // Keep our application logs at Information level
    .AddFilter("RiskDataPlatform", LogLevel.Information);
```

---

## S3 Mock — No Real S3 Connection

All S3 access goes through an `IS3Store` interface. For development and testing, use an in-memory mock implementation. No real S3 connection needed.

### Interface

```csharp
// RiskDataPlatform.Core/Interfaces/IS3Store.cs
public interface IS3Store
{
    Task PutObjectAsync(string path, byte[] data, CancellationToken ct = default);
    Task<byte[]> GetObjectAsync(string path, CancellationToken ct = default);
    Task<bool> ExistsAsync(string path, CancellationToken ct = default);
    Task DeleteObjectAsync(string path, CancellationToken ct = default);
    Task<List<string>> ListObjectsAsync(string prefix, CancellationToken ct = default);
}
```

### In-Memory Mock (for development and tests)

```csharp
// RiskDataPlatform.Infrastructure/Storage/InMemoryS3Store.cs
public class InMemoryS3Store : IS3Store
{
    private readonly ConcurrentDictionary<string, byte[]> _store = new();
    private readonly ILogger<InMemoryS3Store> _logger;

    public InMemoryS3Store(ILogger<InMemoryS3Store> logger) => _logger = logger;

    public Task PutObjectAsync(string path, byte[] data, CancellationToken ct = default)
    {
        _store[path] = data;
        _logger.LogDebug("S3 Mock: PUT {Path} ({SizeKB}KB)", path, data.Length / 1024);
        return Task.CompletedTask;
    }

    public Task<byte[]> GetObjectAsync(string path, CancellationToken ct = default)
    {
        if (!_store.TryGetValue(path, out var data))
            throw new FileNotFoundException($"S3 object not found: {path}");

        _logger.LogDebug("S3 Mock: GET {Path} ({SizeKB}KB)", path, data.Length / 1024);
        return Task.FromResult(data);
    }

    public Task<bool> ExistsAsync(string path, CancellationToken ct = default)
        => Task.FromResult(_store.ContainsKey(path));

    public Task DeleteObjectAsync(string path, CancellationToken ct = default)
    {
        _store.TryRemove(path, out _);
        return Task.CompletedTask;
    }

    public Task<List<string>> ListObjectsAsync(string prefix, CancellationToken ct = default)
        => Task.FromResult(_store.Keys.Where(k => k.StartsWith(prefix)).ToList());
}
```

### Real S3 Implementation (placeholder, not connected)

```csharp
// RiskDataPlatform.Infrastructure/Storage/AwsS3Store.cs
// Create this class with AWSSDK.S3 dependency but don't configure real credentials.
// It should compile and have the correct structure.
// Mark all methods with TODO comments for real implementation.
public class AwsS3Store : IS3Store
{
    // private readonly IAmazonS3 _client;
    // private readonly string _bucketName;

    public Task PutObjectAsync(string path, byte[] data, CancellationToken ct = default)
        => throw new NotImplementedException("Configure real S3 credentials to use this implementation");

    // ... etc
}
```

### DI Registration

```csharp
// In Program.cs:
// Development: use in-memory mock
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddSingleton<IS3Store, InMemoryS3Store>();
}
else
{
    builder.Services.AddSingleton<IS3Store, AwsS3Store>();
}
```

### Test Data Seeder

Create a service that seeds the in-memory S3 store with realistic test data on startup (development only):

```csharp
// RiskDataPlatform.Infrastructure/Storage/TestDataSeeder.cs
// On application startup (development only):
// 1. Create a sample execution manifest
// 2. Generate sample Arrow IPC files for 3-4 books with realistic data
//    (use the schema definitions, generate random but realistic values)
//    - 1 book with ~250 trades
//    - 1 book with ~100 trades
//    - 1 book with ~50 trades
//    - 1 book with ~500 trades
// 3. Store them in the in-memory S3 store
// 4. Create a sample ExecutionGrain with status=Completed
//
// This means when you start the app in development, you immediately
// have data to query without connecting to any external system.
//
// The test data should include:
// - Mix of instrument types (Swap, Future, Option, Swaption)
// - Mix of currencies (USD, EUR, GBP, JPY, AUD)
// - Mix of statuses (Active, Matured)
// - Realistic numeric values for all risk measures
// - BookingTimestamps spread across a business day (09:00-17:00)
//   to test the time slider
// - A few valuation errors on one book to test error display
```

### Test Projects

All unit tests should use InMemoryS3Store. Tests should NOT require any external infrastructure. Grain tests should use Orleans TestKit or Orleans.TestingHost.

---

## Trace Correlation — End-to-End

Every request must be traceable from API entry to S3 read/write:

```
API Request
  └── Activity: "QueryExecutionData" (RiskDataPlatform.Api)
       ├── tag: tenant.id = "default"
       ├── tag: execution.ids = "exec-123"
       │
       ├── Activity: "ReportDataGrain.Query" (RiskDataPlatform.Grains)
       │    ├── tag: grain.key = "default/exec-123"
       │    ├── tag: cache.hit = false
       │    │
       │    ├── Activity: "S3.GetObject" (RiskDataPlatform.Storage)
       │    │    └── tag: s3.path = "default/executions/exec-123/manifest.json"
       │    │
       │    ├── Activity: "S3.GetObject" (RiskDataPlatform.Storage)
       │    │    └── tag: s3.path = "default/executions/exec-123/results/MTL-A.arrow"
       │    │
       │    ├── Activity: "DuckDb.LoadArrowData" (RiskDataPlatform.Query)
       │    │    └── tag: table = "report_data", rows = 250
       │    │
       │    └── Activity: "DuckDb.ExecuteQuery" (RiskDataPlatform.Query)
       │         ├── tag: query.param_count = 3
       │         └── tag: result.row_count = 100
       │
       └── Activity: "FormatResponse" (RiskDataPlatform.Api)
            └── tag: format = "ArrowIpc", size_bytes = 45000
```

This trace appears in the Aspire dashboard automatically during local development.