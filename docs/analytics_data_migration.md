# Analytics Data Migration: ElasticSearch to OpenSearch

This document describes the process for migrating historical analytics data from ElasticSearch to OpenSearch.

## Overview

Analytics data is stored in daily indices:
- `logstash-YYYY.MM.DD` - All search/click events
- `human-logstash-YYYY.MM.DD` - Filtered events (non-bot traffic)

The migration copies 18 months of historical data to OpenSearch while preserving index structure and mappings.

## Prerequisites

1. **Logstash enabled**: Logstash must be configured to write new data to OpenSearch before migration to prevent having to migrate new data.

2. **OpenSearch running**: The OpenSearch cluster must be accessible with the following environment variables configured:
   ```
   OPENSEARCH_ANALYTICS_HOST=https://opensearch-host:9200
   OPENSEARCH_ANALYTICS_USER=admin
   OPENSEARCH_ANALYTICS_PASSWORD=<password>
   ```

3. **ElasticSearch accessible**: The source ElasticSearch cluster must remain accessible during migration.

## Migration Steps

### 1. Verify Connectivity

Check that both clusters are accessible:

```bash
# Check ElasticSearch
curl -u elastic:changeme http://localhost:9200/_cluster/health

# Check OpenSearch
curl -u admin:password https://opensearch-host:9200/_cluster/health
```

### 2. Run Dry Run

Simulate the migration to see what would be migrated:

```bash
bundle exec rake opensearch:analytics:migrate_dry_run
```

Or with custom date range:

```bash
bundle exec rake "opensearch:analytics:migrate_dry_run[2023-06-01,2024-12-01]"
```

### 3. Run Migration

Execute the full migration:

```bash
# Default: migrates last 18 months
bundle exec rake opensearch:analytics:migrate

# Custom date range
bundle exec rake "opensearch:analytics:migrate[2023-06-01,2024-12-01]"

# Single index
bundle exec rake "opensearch:analytics:migrate_index[logstash-2024.01.15]"
```

### 4. Verify Migration

Check migration status:

```bash
bundle exec rake opensearch:analytics:status
```

This compares document counts between ElasticSearch and OpenSearch.

## Rake Tasks Reference

| Task | Description |
|------|-------------|
| `opensearch:analytics:migrate[start_date,end_date]` | Migrate data for date range (default: 18 months) |
| `opensearch:analytics:migrate_dry_run[start_date,end_date]` | Simulate migration without writing data |
| `opensearch:analytics:migrate_index[index_name]` | Migrate a single index |
| `opensearch:analytics:status[start_date,end_date]` | Compare document counts between clusters |

## Date Format

All dates should be in `YYYY-MM-DD` format:
```bash
bundle exec rake "opensearch:analytics:migrate[2023-06-01,2024-12-01]"
```

## Post-Migration

After successful migration:

1. **Verify data**: Run `opensearch:analytics:status` to confirm all documents migrated
2. **Enable feature flag**: Set `OPENSEARCH_APP_ENABLED=true` in environment
3. **Test queries**: Verify analytics queries return expected results
4. **Monitor**: Check logs for any errors

## Rollback

To rollback:

1. Set `OPENSEARCH_APP_ENABLED=false`
2. Restart the application
3. Analytics queries will use ElasticSearch again

## Troubleshooting

### Connection Errors

Verify environment variables are set correctly:
```ruby
Rails.application.config_for(:opensearch_analytics_client)
```

### Missing Indices

Re-run migration for specific dates:
```bash
bundle exec rake "opensearch:analytics:migrate[2024-01-01,2024-01-31]"
```

### Document Count Mismatch

The migration is idempotent - re-running will update existing documents:
```bash
bundle exec rake "opensearch:analytics:migrate_index[logstash-2024.01.15]"
```

## Technical Details

- **Batch size**: 1000 documents per scroll request
- **Scroll timeout**: 5 minutes
- **Idempotent**: Uses document IDs, safe to re-run
- **Index creation**: Copies mappings and settings from source
