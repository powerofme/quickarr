# Risk Data Platform — Foundation Build

## Overview

Build a production-grade foundation for a risk data platform using .NET 8, Orleans 10, Aspire, DuckDB, Apache Arrow, and SignalR. This will serve as the boilerplate for a commodities trading risk system used by 200+ users across 15 desks.

The system serves risk reports (PnL, PAA, Greeks, etc.) to AG Grid (Server-Side Row Model) in an Electron desktop app. Reports are produced by an IBM Symphony Grid compute cluster and stored on S3 as Apache Arrow IPC files, partitioned by book. The platform uses Orleans grains to manage execution lifecycle, data querying (via DuckDB), real-time notifications (via SignalR), and report comparison.

## Technical Stack

- .NET 8 + C# 12
- Microsoft Orleans 10.x (latest stable)
- .NET Aspire (AppHost + ServiceDefaults)
- Apache Arrow (Apache.Arrow NuGet) — Arrow IPC file format with dictionary encoding
- DuckDB (DuckDB.NET.Data NuGet) — in-process columnar query engine
- SignalR — real-time notifications
- AWSSDK.S3 — S3 storage for Arrow files
- Microsoft.Data.SqlClient — SQL Server for Orleans grain state
- xUnit + FluentAssertions — unit testing
- BenchmarkDotNet — benchmarks

## Project Structure

```
RiskDataPlatform/
├── src/
│   ├── RiskDataPlatform.AppHost/                 # Aspire AppHost
│   │   └── Program.cs
│   │
│   ├── RiskDataPlatform.ServiceDefaults/         # Aspire ServiceDefaults
│   │   └── Extensions.cs
│   │
│   ├── RiskDataPlatform.Api/                     # ASP.NET Core + Orleans co-hosted
│   │   ├── Program.cs                            # Full DI setup, middleware pipeline
│   │   ├── Endpoints/
│   │   │   ├── ExecutionEndpoints.cs
│   │   │   ├── DataQueryEndpoints.cs
│   │   │   ├── DebugInfoEndpoints.cs
│   │   │   ├── IncrementalEndpoints.cs
│   │   │   ├── ComparisonEndpoints.cs
│   │   │   ├── ExternalEndpoints.cs
│   │   │   ├── ValuationErrorEndpoints.cs
│   │   │   ├── ConfigEndpoints.cs
│   │   │   ├── HealthEndpoints.cs
│   │   │   ├── ReplayEndpoints.cs
│   │   │   └── AdminEndpoints.cs
│   │   ├── Middleware/
│   │   │   ├── TenantMiddleware.cs
│   │   │   ├── AuthPlaceholderMiddleware.cs
│   │   │   ├── RequestSanitizerMiddleware.cs
│   │   │   ├── ErrorHandlingMiddleware.cs
│   │   │   └── EventJournalMiddleware.cs
│   │   ├── Hubs/
│   │   │   └── RiskHub.cs
│   │   └── Formatters/
│   │       ├── ResponseFormatNegotiator.cs
│   │       └── ResponseFormatter.cs
│   │
│   ├── RiskDataPlatform.Core/                    # Domain models, interfaces, contracts
│   │   ├── Models/
│   │   │   ├── Execution.cs
│   │   │   ├── ExecutionDebugInfo.cs
│   │   │   ├── ExecutionStatus.cs
│   │   │   ├── ReportQueryRequest.cs
│   │   │   ├── SsrmRequest.cs
│   │   │   ��── SsrmResponse.cs
│   │   │   ├── ComparisonRequest.cs
│   │   │   ├── ComparisonSummary.cs
│   │   │   ├── ValuationError.cs
│   │   │   ├── BookStatus.cs
│   │   │   ├── ErrorResponse.cs
│   │   │   ├── ErrorCodes.cs
│   │   │   ├── ResponseFormat.cs
│   │   │   ├── RiskMeasureConfig.cs
│   │   │   ├── TenantConfiguration.cs
│   │   │   ├── SystemHealthStatus.cs
│   │   │   ├── ExecutionManifest.cs
│   │   │   ├── TimelineRequest.cs
│   │   │   └── ReplayModels.cs
│   │   ├── Interfaces/
│   │   │   ├── IReportDataStore.cs
│   │   │   ├── IReportQueryEngine.cs
│   │   │   ├── IEventJournal.cs
│   │   │   ├── ITenantContext.cs
│   │   │   └── IS3Client.cs
│   │   └── Constants/
│   │       ├── GrainKeys.cs
│   │       └── ErrorResponses.cs
│   │
│   ├── RiskDataPlatform.Grains/                  # Orleans grain implementations
│   │   ├── ExecutionGrain.cs
│   │   ├── ReportDataGrain.cs
│   │   ├── ComparisonGrain.cs
│   │   ├── DeskGrain.cs
│   │   ├── NotificationGrain.cs
│   │   └── Interfaces/
│   │       ├── IExecutionGrain.cs
│   │       ├── IReportDataGrain.cs
│   │       ├── IComparisonGrain.cs
│   │       ├── IDeskGrain.cs
│   │       └── INotificationGrain.cs
│   │
│   ├── RiskDataPlatform.Arrow/                   # Arrow serialization + S3 storage
│   │   ├── Schemas/
│   │   │   └── ReportSchemas.cs
│   │   ├── ArrowFileWriter.cs
│   │   ├── ArrowFileReader.cs
│   │   ├── BookAccumulator.cs
│   │   ├── ArrowResultMerger.cs
│   │   ├── IncrementalArrowWriter.cs
│   │   ├── DictionaryEncodedBuilder.cs
│   │   └── S3ArrowStore.cs
│   │
│   ├── RiskDataPlatform.Query/                   # DuckDB query engine
│   │   ├── DuckDbQueryEngine.cs
│   │   ├── SsrmToDuckDbVisitor.cs
│   │   ├── ComparisonQueryBuilder.cs
│   │   └── ArrowDataLoader.cs
│   │
│   └── RiskDataPlatform.Infrastructure/          # Cross-cutting concerns
│       ├── Tenancy/
│       │   ├── OrleansGrainTenantContext.cs
│       │   └── TenantConfigProvider.cs
│       ├── Health/
│       │   └── SystemHealthService.cs
│       ├── EventJournal/
│       │   └── NoOpEventJournal.cs
│       └── Orleans/
│           └── RollingUpgradeExtensions.cs
│
├── tests/
│   ├── RiskDataPlatform.Tests.Unit/
│   │   ├── Query/
│   │   │   ├── SsrmToDuckDbVisitorTests.cs
│   │   │   ├── DuckDbQueryEngineTests.cs
│   │   │   └── ComparisonQueryBuilderTests.cs
│   │   ├── Arrow/
│   │   │   ├── ArrowFileWriterTests.cs
│   │   │   ├── ArrowFileReaderTests.cs
│   │   │   ├── BookAccumulatorTests.cs
│   │   │   ├── DictionaryEncodedBuilderTests.cs
│   │   │   └── ArrowResultMergerTests.cs
│   │   ├── Api/
│   │   │   ├── RequestSanitizerTests.cs
│   │   │   ├── TenantMiddlewareTests.cs
│   │   │   ├── ResponseFormatNegotiatorTests.cs
│   │   │   └── ErrorHandlingMiddlewareTests.cs
│   │   ├── Grains/
│   │   │   ├── ExecutionGrainTests.cs
│   │   │   ├── ReportDataGrainTests.cs
│   │   │   ├── DeskGrainTests.cs
│   │   │   └── ComparisonGrainTests.cs
│   │   └── Models/
│   │       ├── GrainKeysTests.cs
│   │       └── ErrorResponseTests.cs
│   │
│   └── RiskDataPlatform.Tests.Benchmarks/
│       ├── JsonVsArrowResponseBenchmark.cs
│       ├── DuckDbQueryBenchmark.cs
│       └── ApiLoadSimulation.cs
│
├── RiskDataPlatform.sln
└── README.md
```

## Core Design Principles

### 1. Virtual Tenancy
- Tenant ID comes from `X-Tenant-Id` HTTP header
- Default to `"default"` if header is absent
- Tenant ID is NOT in the URL — hidden from external users
- Tenant propagated through Orleans `RequestContext` to all grain calls
- All grain keys are prefixed with tenant: `"{tenantId}/{logicalKey}"`
- Tenant configuration is hierarchical: market data, pricing, storage, book access

### 2. Execution Model
- Every report run is an "execution" identified by an execution ID (GUID format)
- Execution knows: which desks, which books (resolved from desk config), report type, as-of date
- Execution status includes per-book status with valuation error counts and book NAME (not ID)
- UI uses this to paint portfolio tree with RAG colours

### 3. Multi-Execution Query Support
- All GET APIs that take execution ID should accept multiple execution IDs
- Backend validation: max 1 execution per desk per report type combination
- Exception: comparison endpoint allows multiple per desk (that's its purpose)

### 4. Arrow IPC File Format (NOT Parquet)
- Store results as Arrow IPC FILE format on S3 (not stream, not Parquet)
- Reason: near-zero CPU on write (no encoding/compression overhead)
- Trade-off: larger files, but CPU is more expensive than storage on virtual CPUs
- Dictionary encoding ON for categorical string columns (DeskId, BookId, Currency, InstrumentType, Status, Trader, Strategy, Counterparty)
- Dictionary encoding OFF for unique strings (TradeId) and all numerics
- Use smallest index type based on cardinality (Int8 for <127, Int16 for <32K, Int32 for larger)
- One Arrow file per book on S3
- Cross-language compatible: Python writes byte[], C# reads via MemoryStream

### 5. S3 Layout
```
s3://risk-data/{tenantId}/executions/{executionId}/
├─��� manifest.json
├── market-data/
│   ├── curves.arrow
│   └── surfaces.arrow
└── results/
    ├── {bookName}.arrow
    ├── {bookName}.arrow
    └── ...
```

### 6. DuckDB
- In-process, per-grain DuckDB instance
- Reads Arrow IPC files via MemoryStream (byte[] → ArrowFileReader → RecordBatch → DuckDB table)
- Handles all SSRM queries (filters, sort, group, pagination) as SQL
- Dictionary-encoded columns accelerate string filtering (integer compare vs string compare)

### 7. Response Format Negotiation
- Default: Arrow IPC stream (application/vnd.apache.arrow.stream)
- Fallback: JSON (application/json)
- Optional: Columnar JSON (application/vnd.columnar+json)
- Resolved from: request body field > Accept header > default
- Internally always Arrow — conversion to JSON happens only at the API edge

### 8. SignalR Notifications
- Hub at /hubs/risk
- Users auto-join desk groups based on JWT claims on connect
- Events: ExecutionCompleted, ExecutionStatusChanged, TradePriced, HealthStatusChanged
- TradePriced is debounced/batched (every 500ms during bursts)
- No PubSub grain, no Client grain — use native SignalR groups

### 9. Error Handling
- Standardized ErrorResponse on ALL error paths
- Error codes: EXEC-xxx, DATA-xxx, AUTH-xxx, RATE-xxx, SYS-xxx, INPUT-xxx
- Transient errors include IsTransient=true and RetryAfterSeconds
- HTTP 503 + Retry-After header for transient errors
- TraceId on every error for support correlation

### 10. Rolling Upgrade Safety
- All serializable types use [GenerateSerializer] with [Id(n)] on every field
- Adding fields: always use new [Id(n)] number, make nullable
- Never remove or renumber fields
- Orleans GrainVersioningOptions: BackwardCompatible + MinimumVersion
- API versioning: /api/v1/ prefix, additive changes only

---

## API Endpoints — Complete Specification

### Tenant Header
All endpoints read tenant from `X-Tenant-Id` header. Default: `"default"`.
Tenant is NOT in the URL.

### 1. Execution Management

#### POST /api/v1/executions
Create a new report execution.

Request body:
```json
{
  "reportType": "Risk",
  "deskIds": ["Metals", "Energy"],
  "asOfDate": "2025-02-08",
  "riskMeasures": ["Delta", "Vega", "Gamma"]  // optional, null = all for report type
}
```

Response 202:
```json
{
  "executionId": "exec-a3f8c2d1-4b5e-4f3a-9c1d-000000001234",
  "status": "Pending"
}
```

#### GET /api/v1/executions?ids={id1},{id2}
Get status and metadata for one or more executions.
Validation: max 1 execution per desk per report type.

Response 200:
```json
{
  "executions": [
    {
      "executionId": "exec-...",
      "reportType": "Risk",
      "deskIds": ["Metals"],
      "resolvedBooks": ["MTL-A", "MTL-B", "MTL-C"],
      "asOfDate": "2025-02-08",
      "status": "Completed",
      "createdAt": "...",
      "completedAt": "...",
      "requestedBy": "trader1",
      "bookStatus": {
        "MTL-A": { "bookName": "Metals Book A", "tradeCount": 250, "errorCount": 0 },
        "MTL-B": { "bookName": "Metals Book B", "tradeCount": 180, "errorCount": 2 },
        "MTL-C": { "bookName": "Metals Book C", "tradeCount": 95, "errorCount": 12 }
      }
    }
  ]
}
```

#### DELETE /api/v1/executions/{executionId}
Cancel a running execution.

#### GET /api/v1/desks/{deskId}/executions
List executions for a desk. Supports query params: reportType, fromDate, toDate, status.

#### GET /api/v1/desks/{deskId}/executions/latest
Get latest completed execution per report type for a desk.

### 2. Data Query

#### POST /api/v1/executions/query
Query report data for one or more executions.

Request body:
```json
{
  "executionIds": ["exec-123", "exec-456"],
  "ssrm": {
    "startRow": 0,
    "endRow": 100,
    "sortModel": [{ "colId": "TotalPnL", "sort": "desc" }],
    "filterModel": {
      "Currency": { "filterType": "set", "values": ["USD", "EUR"] }
    },
    "rowGroupCols": [],
    "valueCols": [],
    "groupKeys": []
  },
  "books": ["MTL-A", "MTL-B"],
  "columnModules": ["Core", "PnLAttribution"],
  "format": "ArrowIpc",
  "tradesAsOf": "2025-02-08T14:30:00Z",
  "tradesFrom": null,
  "timeline": {
    "measureColumn": "TotalPnL",
    "aggFunc": "sum",
    "bucketMinutes": 30
  }
}
```

Backend validation: max 1 execution per desk per report type in executionIds.

Response: Arrow IPC bytes with content-type `application/vnd.apache.arrow.stream` (or JSON if requested).

#### POST /api/v1/executions/{executionId}/aggregated
Aggregated/grouped query (summary views).

#### GET /api/v1/executions/{executionId}/schema
Column definitions for AG Grid dynamic configuration.

#### POST /api/v1/executions/{executionId}/export
Full export (CSV, Excel, Arrow).

#### GET /api/v1/executions/{executionId}/measures
Risk measures and variations available in this execution.

### 3. Debug Info

#### GET /api/v1/executions/{executionId}/debug-info
Full debug information (risk spec, model params, library version, grid session, runtime, issues).

#### GET /api/v1/executions/{executionId}/debug-info/quick
Compact summary (versions, timing, issue count).

#### GET /api/v1/executions/{executionId}/debug-info/market-data
Market data details (snapshot time, curves, surfaces, fixings, input hash).

#### GET /api/v1/executions/{executionId}/debug-info/runtime
Time breakdown by phase.

#### GET /api/v1/executions/{executionId}/debug-info/grid
Grid execution details (session ID, task counts, durations).

#### GET /api/v1/executions/{executionId}/debug-info/issues
Warnings and errors from execution.

### 4. Valuation Errors

#### POST /api/v1/executions/{executionId}/valuation-errors
Get valuation errors for specific books.

Request body:
```json
{
  "bookNames": ["Metals Book A", "Metals Book C"]
}
```

Response 200:
```json
{
  "executionId": "exec-...",
  "errors": {
    "Metals Book C": [
      {
        "tradeId": "T-1001",
        "bookName": "Metals Book C",
        "instrumentType": "Swaption",
        "errorCode": "VAL-101",
        "errorMessage": "Missing vol surface for USD 10Y",
        "severity": "Error",
        "timestamp": "..."
      }
    ]
  },
  "summary": {
    "Metals Book A": { "errorCount": 0 },
    "Metals Book C": { "errorCount": 12 }
  }
}
```

### 5. Incremental Mode

#### POST /api/v1/executions/{executionId}/incremental/start
Enable incremental mode. Max 2 per desk.

#### POST /api/v1/executions/{executionId}/incremental/stop
Stop incremental mode.

#### GET /api/v1/executions/{executionId}/incremental/status
Get incremental status.

### 6. Comparison

#### POST /api/v1/compare
Create comparison between 2+ executions.

Request body:
```json
{
  "executionIds": ["exec-455", "exec-456", "exec-457"],
  "compareColumns": ["TotalPnL", "Delta", "Vega"],
  "changeThreshold": 0.01
}
```

#### POST /api/v1/compare/{comparisonId}/query
Query comparison diff with SSRM.

#### GET /api/v1/compare/{comparisonId}/summary
High-level comparison stats.

#### GET /api/v1/compare/{comparisonId}/market-data-diff
Market data differences between compared executions.

### 7. External Access (date-based)

#### POST /api/v1/external/desks/{deskId}/reports/{reportType}/{date}/query
Query by date. Auto-resolves to latest completed execution.

#### GET /api/v1/external/desks/{deskId}/reports/{reportType}/available-dates
List dates with completed reports.

#### GET /api/v1/external/desks/{deskId}/reports/{reportType}/{date}/summary
Summary for a date.

### 8. Configuration & Discovery

#### GET /api/v1/desks
List desks accessible to current user.

#### GET /api/v1/available-measures
All risk measures and variations (config-driven).

### 9. Replay (Stubbed — returns 501)

#### POST /api/v1/replay/sessions
#### GET /api/v1/replay/sessions/{sessionId}
#### PUT /api/v1/replay/sessions/{sessionId}/control
#### DELETE /api/v1/replay/sessions/{sessionId}
#### GET /api/v1/replay/available-dates

All return 501 Not Implemented.

### 10. Admin

#### POST /api/v1/admin/tenants
Create virtual tenant.

#### GET /api/v1/admin/tenants
List tenants.

#### DELETE /api/v1/admin/tenants/{tenantId}
Remove tenant (cannot delete "default").

### 11. Health

#### GET /health/live
Simple liveness (200 OK, no auth).

#### GET /health/status
RAG status for all components: Orleans cluster, analytic silos, grid, SQL, S3, trade feed, market data feed, static data feed, SignalR, memory. Each component has Green/Amber/Red status with metrics.

---

## Arrow Schema — Default for Commodities Risk Platform

### Core Schema (all reports)
Dictionary-encoded string columns marked with [DICT].

| Column | Type | Dictionary | Notes |
|--------|------|-----------|-------|
| TradeId | string | No | Unique per trade |
| ExternalRef | string | No | External system reference |
| BookId | string | DICT Int32 | ~2000 unique |
| BookName | string | DICT Int16 | Display name |
| DeskId | string | DICT Int8 | ~15 unique |
| DeskName | string | DICT Int8 | Display name |
| InstrumentType | string | DICT Int16 | ~50 unique (Swap, Swaption, Future, Option, etc.) |
| InstrumentSubType | string | DICT Int16 | ~100 unique |
| Counterparty | string | DICT Int16 | ~500 unique |
| Currency | string | DICT Int8 | ~30 unique |
| SettlementCurrency | string | DICT Int8 | ~30 unique |
| Status | string | DICT Int8 | ~5 (Active, Matured, Cancelled, etc.) |
| Trader | string | DICT Int8 | ~200 unique |
| Strategy | string | DICT Int8 | ~50 unique |
| TradeDate | Date32 | No | |
| MaturityDate | Date32 | No | |
| ValueDate | Date32 | No | |
| BookingTimestamp | Timestamp | No | For time slider |
| Notional | Double | No | |
| Quantity | Double | No | Contract quantity |
| StrikePrice | Double | No | For options |
| UnderlyingPrice | Double | No | Current underlying price |

### Risk Schema (Greeks)
All Double type, no dictionary encoding.

| Column | Notes |
|--------|-------|
| Delta | First-order price sensitivity |
| DeltaContractUnits | Delta in contract units |
| DeltaLots | Delta in lots |
| DeltaUSD | Delta converted to USD |
| Gamma | Second-order price sensitivity |
| GammaUSD | Gamma in USD |
| Vega | Volatility sensitivity (1% move) |
| VegaUSD | Vega in USD |
| Theta | Time decay (1 day) |
| ThetaUSD | Theta in USD |
| Rho | Interest rate sensitivity |
| RhoUSD | Rho in USD |
| DV01 | Dollar value of 1bp IR move |
| CS01 | Credit spread sensitivity |
| ConvexityAdjustment | |

### PnL Attribution Schema
All Double type.

| Column | Notes |
|--------|-------|
| TotalPnL | Total P&L |
| RealizedPnL | Realized portion |
| UnrealizedPnL | Unrealized portion |
| DailyPnL | Today's P&L |
| MTDPnL | Month-to-date |
| YTDPnL | Year-to-date |
| NewTradeEffect | PnL from new trades |
| MarketMoveEffect | PnL from market movements |
| TimeDecayEffect | PnL from time passing |
| CashflowEffect | PnL from cashflows |
| FundingEffect | PnL from funding |
| ModelChangeEffect | PnL from model changes |
| TradeAmendEffect | PnL from trade amendments |
| Unexplained | Residual unexplained PnL |

### Commodity Attribution Schema
All Double type.

| Column | Notes |
|--------|-------|
| SpotPriceEffect | PnL from spot price change |
| ForwardCurveEffect | PnL from forward curve change |
| BasisEffect | PnL from basis change |
| VolatilityEffect | PnL from vol change |
| CorrelationEffect | PnL from correlation change |
| SeasonalityEffect | PnL from seasonality |
| FxSpotEffect | PnL from FX spot change |
| FxForwardEffect | PnL from FX forward change |
| FxVolEffect | PnL from FX vol change |
| CrossCurrencyBasisEffect | PnL from cross-currency basis |

### Report Type → Schema Mapping
- Risk: Core + Risk
- PnL: Core + PnL Attribution
- PAA: Core + PnL Attribution + Commodity Attribution
- Custom: Core + user-selected measures

### Risk Measure Configuration (appsettings.json)
```json
{
  "RiskMeasures": [
    {
      "GroupName": "Delta",
      "Description": "First-order price sensitivity",
      "Variations": [
        { "DisplayName": "Delta (Contract Units)", "Key": "delta_contracts", "AnalyticResultType": "RawDelta", "RequiredColumns": ["DeltaContractUnits"] },
        { "DisplayName": "Delta (Lots)", "Key": "delta_lots", "AnalyticResultType": "RawDelta", "Transformation": "to_lots", "RequiredColumns": ["DeltaLots"] },
        { "DisplayName": "Delta (USD)", "Key": "delta_usd", "AnalyticResultType": "RawDelta", "Filters": { "currency": "USD" }, "RequiredColumns": ["DeltaUSD"] }
      ]
    },
    {
      "GroupName": "Gamma",
      "Variations": [
        { "DisplayName": "Gamma", "Key": "gamma", "AnalyticResultType": "RawGamma", "RequiredColumns": ["Gamma"] },
        { "DisplayName": "Gamma (USD)", "Key": "gamma_usd", "AnalyticResultType": "RawGamma", "RequiredColumns": ["GammaUSD"] }
      ]
    },
    {
      "GroupName": "Vega",
      "Variations": [
        { "DisplayName": "Vega (1% move)", "Key": "vega_1pct", "AnalyticResultType": "RawVega", "RequiredColumns": ["Vega"] },
        { "DisplayName": "Vega (USD)", "Key": "vega_usd", "AnalyticResultType": "RawVega", "RequiredColumns": ["VegaUSD"] }
      ]
    }
  ]
}
```

---

## Middleware Pipeline Order

```csharp
app.UseMiddleware<ErrorHandlingMiddleware>();      // 1. Catch all errors
app.UseMiddleware<TenantMiddleware>();              // 2. Resolve tenant from X-Tenant-Id header
app.UseMiddleware<RequestSanitizerMiddleware>();    // 3. Validate & limit requests
app.UseMiddleware<EventJournalMiddleware>();        // 4. Record for future replay (no-op now)
app.UseMiddleware<AuthPlaceholderMiddleware>();     // 5. Auth placeholder (pass all requests)
```

---

## Testing Requirements — ALL TESTS MUST PASS

### SSRM Visitor Tests
- Text filters: contains, equals, startsWith, endsWith, notContains, notEqual
- Number filters: equals, greaterThan, lessThan, inRange
- Set filters: IN clause with multiple values
- Date filters: equals, greaterThan, inRange
- Sort: single column, multiple columns, asc/desc
- Pagination: LIMIT/OFFSET from startRow/endRow
- Grouping: single level, multi-level, with aggregation
- Group drill-down: groupKeys filtering
- Time slider: tradesAsOf, tradesFrom, combined range
- Timeline query: time_bucket aggregation
- SQL injection prevention: invalid column names rejected
- Empty/null filters handled gracefully

### DuckDB Engine Tests
- Register Arrow data and query it
- Parameterized queries work correctly
- Multiple tables registered (for comparison)
- FULL OUTER JOIN for comparison queries
- Results returned as Arrow RecordBatch
- Concurrent read queries (thread safety)

### Arrow Tests
- Write Arrow IPC file with mixed column types
- Read Arrow IPC file back and verify data
- Dictionary-encoded columns: write and read correctly
- Dictionary index type selection based on cardinality (Int8/Int16/Int32)
- BookAccumulator: merge rows from multiple batches by book
- Cross-language compatibility: write bytes, read from MemoryStream
- Round-trip: build → write → read → verify

### Request Sanitizer Tests
- Multi-execution validation: reject 2 executions for same desk+type
- Allow: different desks, different types
- Comparison endpoint: exempt from the restriction
- Max books per request enforced
- Max rows per page enforced

### Tenant Middleware Tests
- X-Tenant-Id header present → use it
- X-Tenant-Id header absent → default to "default"
- Tenant propagated to Orleans RequestContext

### Response Format Tests
- Explicit format in body takes priority
- Accept header respected
- Default to Arrow IPC
- JSON conversion produces valid JSON with row-oriented structure
- Columnar JSON produces column-oriented structure

### Error Handling Tests
- ErrorResponse shape is consistent
- Transient errors include RetryAfterSeconds
- HTTP status codes mapped correctly
- TraceId included in all errors

### Grain Tests
- ExecutionGrain: create, update status, complete, get debug info
- ReportDataGrain: load data, query, LRU cache hit on identical query, cache invalidation on data update
- DeskGrain: incremental ration (allow 2, reject 3rd), release slot
- ComparisonGrain: initialize with 2 executions, manifest diff (changed/added/removed books)

---

## Benchmark Requirements

### JSON vs Arrow IPC
- Generate sample report data (1000 rows × 50 columns)
- Serialize as JSON
- Serialize as Arrow IPC stream
- Compare: byte size, serialization time, deserialization time
- Output: table showing size ratio and speed ratio

### DuckDB Query Performance
- Load 10K, 50K, 100K rows into DuckDB from Arrow
- Run SSRM queries: paginated, filtered, grouped, sorted
- Measure: query latency at each scale

### API Load Simulation
- Simulate 15 concurrent users hitting the same execution's query endpoint
- Verify: first request executes DuckDB, subsequent requests hit LRU cache
- Measure: response times under load
- Verify: response consistency (same query = same results)

---

## Key Implementation Notes

1. **Auth is a placeholder**: Create `AuthPlaceholderMiddleware` that sets a dummy user with access to all desks. Real auth will be added later. All endpoints should still check for a user principal in HttpContext.

2. **Event journal is no-op**: Create `NoOpEventJournal` that implements `IEventJournal` but does nothing. The middleware pipeline includes it so the structure is ready for replay.

3. **Replay endpoints return 501**: Define the route contracts but return `Results.StatusCode(501)` with a message "Replay feature not yet implemented".

4. **Grain state in SQL**: Use Orleans ADO.NET grain storage with Microsoft.Data.SqlClient. For local development, include SQL Server container in Aspire AppHost.

5. **Grain keys**: All grain keys prefixed with tenant: `GrainKeys.ForExecution(tenantId, executionId)` returns `"{tenantId}/{executionId}"`.

6. **ReportDataGrain is [Reentrant]**: Multiple users query the same execution simultaneously. DuckDB reads are safe to interleave. Write operations (data updates) use SemaphoreSlim for exclusive access.

7. **ComparisonGrain is ephemeral**: [KeepAlive("00:15:00")] — auto-deactivates after 15 minutes.

8. **Book names, not IDs**: All API responses use book NAME (display name) not internal book ID. This makes the API usable by external consumers who don't know internal IDs.

9. **Orleans 10.x**: Use the latest Orleans 10 packages. Configure for rolling upgrade with BackwardCompatible versioning strategy.

10. **All tests must compile and pass**: Do not leave failing tests. If an implementation is too complex to test fully, create a simpler version that still tests the core logic.