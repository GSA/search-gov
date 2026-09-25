# OpenSearch query cache

Search.gov caches one page of OpenSearch document-search JSON in Redis for 15 minutes so repeat queries (especially during traffic spikes) do not hit the cluster again.

This is an application-level cache. Govboxes, SERP rendering, and impression logging still run on every request.

## Where it lives

- Rails.cache → `REDIS_CACHE_URL` → ElastiCache `{env}-searches` / `dgs-prod-searches`
- Namespace: `searches`
- Key: SHA256 of affiliate, index, offset/size, case-folded formatted query, locale, and filters
- TTL: `OPENSEARCH_CACHE_DURATION` minutes (default `15`). Read per request. `0` disables caching.

`OPENSEARCH_CACHE_DURATION` is an SSM parameter. Changing it requires a Puma restart so processes see the new value.

## Bypass (maintainers only)

Add `memory=false` to a web or API search URL. That request queries OpenSearch and does **not** write the result. Do not share this parameter with affiliates. Do not use `Cache-Control: no-cache`; flood traffic already sends that header.

## Monitoring

Each OpenSearch impression includes:

```json
"diagnostics": [{ "module": "SRCH", "cached": true }]
```

That JSON is written to `log/impressions.log` (Logstash) and `Rails.logger` (CloudWatch). Filter on `diagnostics.cached`.

Also watch ElastiCache `dgs-prod-searches` memory and evictions, plus Puma/request latency versus OpenSearch latency.

## Clearing the cache

`Rails.cache.clear` flushes the **entire** searches Redis cluster (everything on `REDIS_CACHE_URL`), not only OpenSearch query keys. After the Bing cache removal that cluster is mostly this feature, but treat clear as a cluster wipe.

There is no per-affiliate flush in Phase 1. The 15-minute TTL is the normal invalidation. Index updates can take up to that long to appear in cached results.

## Redis failure

Production `redis_cache_store` uses short connect/read/write timeouts and a fail-open error handler. If Redis is down or slow, searches fall through to OpenSearch. Client errors are never written to the cache. Successful empty hit sets are cached.
