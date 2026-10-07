# OpenSearch query cache

Search.gov can cache one page of OpenSearch document-search JSON in Redis for 15 minutes so repeat queries (especially during traffic spikes) do not hit the cluster again.

This is an application-level cache. Govboxes, SERP rendering, and impression logging still run on every request.

## When a request uses the cache

All of these must be true:

1. `REDIS_CACHE_ON` is `true` (case-insensitive). Unset or any other value means off.
2. The affiliate has **Search cache enabled** checked in Super Admin > Sites > Enable/disable Settings. New and existing sites default to off.
3. `REDIS_CACHE_DURATION` is a positive whole number of minutes (default `15`; non-numeric values fall back to `15`, `0` or less disables).

There is no per-request bypass. See "Getting fresh results" below.

## Where it lives

- Rails.cache -> `REDIS_CACHE_URL` -> ElastiCache `{env}-searches` / `dgs-prod-searches`
- Namespace: `searches`
- Key: `searches:<affiliate_id>:v1:<sha256>`. The digest covers the index, offset, size, and the full OpenSearch request body. Any param that changes the OpenSearch request (sitelimit, siteexclude, facets, dates, sort, advanced query fields, affiliate domain edits) changes the key.
- Only the user's query text is case-folded (`Epstein`, `EPSTEIN`, and ` epstein ` share a key). Uppercase `AND`/`OR`/`NOT` stay distinct. Site paths and other filters keep their case.
- Timestamps are floored to the minute in the key so relative ranges such as "past hour" stay cacheable.
- Bump `CACHE_KEY_VERSION` in `OpenSearch::DocumentSearch` if the cached payload shape changes; old entries then age out on their own.

`spec/controllers/searches_controller_cache_key_spec.rb` and `spec/controllers/api/v2/searches_controller_cache_key_spec.rb` fail when a newly permitted web or API param is not classified as either changing the key or not reaching OpenSearch.

## Settings and how fast they take effect

| Lever | Scope | Takes effect |
| --- | --- | --- |
| Super Admin "Search cache enabled" | One site | Next request |
| `Affiliate.update_all(search_cache_enabled: false)` | All sites | Next request |
| `REDIS_CACHE_ON` / `REDIS_CACHE_DURATION` in SSM | Global | Next deploy |

SSM values reach the app only when `cicd-scripts/fetch_env_vars.sh` rewrites `.env` during a deploy. A Puma restart alone does **not** pick up a changed SSM value. Terraform seeds these params once (`ignore_changes = [value]`); edit them in SSM after that.

## Getting fresh results

The `disable_search_cache` request param was removed because the repo is public and anyone could use it to force OpenSearch misses during a flood. The param is now ignored: requests that still carry it are served from the cache, and it stays out of impression `params`. `Cache-Control: no-cache` is also ignored, since flood traffic sends that header.

To see fresh OpenSearch results, in order of blast radius:

1. Flush one site (see "Clearing the cache"). The next search for that site is a `miss`.
2. Uncheck **Search cache enabled** for the site. Its searches report `disabled` until it is re-checked.
3. `Affiliate.update_all(search_cache_enabled: false)` for every site.
4. Set `REDIS_CACHE_ON=false` in SSM and redeploy, only if the code path itself must be off.

## Local development

`.env.development` ships with `REDIS_CACHE_ON=false`, so development keeps its usual cache store and does not need Redis. To try the cache locally:

1. Start Redis (`cd ../search-services && docker compose up redis`).
2. Turn the cache on and restart the server. Development then uses `redis_cache_store` on `REDIS_CACHE_URL`.
   - Rails on the host: set `REDIS_CACHE_ON=true` in `.env.development.local` or the shell.
   - Rails in the search-services `search-gov` container: set both variables in the shell, for example `REDIS_CACHE_ON=true REDIS_CACHE_URL=redis://redis:6379 bin/rails s`, or pass them with `docker compose run -e REDIS_CACHE_ON=true -e REDIS_CACHE_URL=redis://redis:6379 search-gov bash`. `.env.development.local` has no effect there, because Compose already loads `.env.development` into the container environment and dotenv does not overwrite variables that are already set.
3. Check **Search cache enabled** for a site in Super Admin, then run the same search twice. The second impression shows `cache: hit`.

## Monitoring

Each OpenSearch impression includes:

```json
"diagnostics": [{ "module": "SRCH", "cached": true, "cache": "hit" }]
```

`cache` is one of `hit`, `miss`, or `disabled`. `cached` is `true` only for `hit`. Hit rate is `hit / (hit + miss)`.

That JSON is written to `log/impressions.log` (Logstash) and `Rails.logger` (CloudWatch). Filter on `diagnostics.cache`.

Also watch ElastiCache `dgs-prod-searches` memory, evictions, and CPU, plus request latency versus OpenSearch latency.

## Clearing the cache

Flush one site from a Rails console:

```ruby
Rails.cache.delete_matched("#{affiliate.id}:*", namespace: 'searches')
```

`delete_matched` uses `SCAN`, which is fine for this keyspace. `Rails.cache.clear` flushes the **entire** searches Redis cluster (everything on `REDIS_CACHE_URL`); treat it as a cluster wipe.

The 15-minute TTL is the normal invalidation. Index updates can take up to that long to appear in cached results for enabled sites.

## Rollout and rollback

1. Apply the SSM params (searchgov-tf), then deploy so `.env` picks them up.
2. Enable one site in the AWS development environment, then staging. Search the same query twice; the second impression shows `cache: hit`. Change the query case (hit), add `disable_search_cache=true` (still hit), then uncheck the site (disabled).
3. In production, enable one site and watch hit rate, OpenSearch query rate, p95 latency, and `dgs-prod-searches` memory/evictions.
4. Roll back by unchecking the site (or `update_all` for all sites). Set `REDIS_CACHE_ON=false` and redeploy only if the code path itself must be off.

## Known behavior

- A cold key under a spike still sends parallel identical queries to OpenSearch. `race_condition_ttl` only smooths expiry of an existing key.
- `audience` is a keyword field matched against the raw query. A query that exactly equals an audience value in different case can now share a cached page with its lowercase form.
- The related-searches govbox issues its own OpenSearch query and is not cached.

## Redis failure

Production `redis_cache_store` uses short connect/read/write timeouts and a fail-open error handler. If Redis is down or slow, searches fall through to OpenSearch and each failed call logs a `RedisCacheStore ... failed` warning, so expect one warning per search during an outage. Client errors are never written to the cache. Successful empty hit sets are cached.

During the release that adds `search_cache_enabled`, hosts that boot before `db:migrate` runs treat every site as disabled.
