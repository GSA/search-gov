# BoostedContent (Best Bets) Guide

## Overview

**BoostedContent** (also called "Best Bets") is a feature that allows site administrators to curate and promote important content at the top of search results. These are manually managed entries that appear prominently when users search for specific keywords.

### What Users See

When a user searches, they see "Recommended by [Site Name]" section displaying 2 curated results above the regular search results. Each entry includes:

- **Title** - The headline of the boosted content
- **Description** - A brief summary
- **URL** - Link to the content
- **Keywords** - Search terms that trigger this result (optional)

---

## Data Flow Architecture

BoostedContent follows a **two-stage data flow**:

```
┌─────────────────────────────────────────────────────┐
│ Stage 1: Data Indexing (MySQL → OpenSearch)         │
├─────────────────────────────────────────────────────┤
│                                                      │
│  BoostedContent (MySQL)                             │
│         ↓                                             │
│  ElasticBoostedContentData (transforms data)        │
│         ↓                                             │
│  ElasticResqueIndexer (batch processor via Resque)  │
│         ↓                                             │
│  ElasticBoostedContent.index() (sends to OpenSearch)│
│         ↓                                             │
│  OpenSearch Index                                    │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Stage 2: Search Query (OpenSearch → Results)        │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Search Request (q: "diabetes")                     │
│         ↓                                             │
│  GovboxSet.init_text_best_bets()                    │
│         ↓                                             │
│  ElasticBoostedContent.search_for(options)          │
│         ↓                                             │
│  ElasticBoostedContentQuery (builds query)          │
│         ↓                                             │
│  OpenSearch searches index                          │
│         ↓                                             │
│  ElasticBoostedContentResults (wraps results)       │
│         ↓                                             │
│  @search.boosted_contents (displayed via React)     │
└─────────────────────────────────────────────────────┘
```

### Key Points

- **Data Source (Primary)**: MySQL `boosted_contents` table
- **Data Source (Search)**: OpenSearch/Elasticsearch index
- **Sync Mechanism**: Resque background jobs automatically index changes
- **React Component**: Results are rendered by `BestBets` React component, not HAML templates

---

## Required Fields and Setup

### Critical Fields

When creating or editing a BoostedContent entry, these fields are **required**:

| Field              | Type     | Description                        | Example                         |
| ------------------ | -------- | ---------------------------------- | ------------------------------- |
| `title`            | String   | The headline of the boosted result | "Diabetes Self-Management"      |
| `url`              | String   | Full URL with http/https prefix    | `https://example.gov/diabetes`  |
| `description`      | String   | Brief summary of the content       | "Learn about managing diabetes" |
| `status`           | Enum     | Must be "active" or "inactive"     | `"active"`                      |
| `publish_start_on` | Date     | When the result becomes visible    | `2026-08-12`                    |
| `publish_end_on`   | **Date** | **When the result expires**        | `2027-08-12` (REQUIRED!)        |
| `affiliate_id`     | Integer  | Which site this belongs to         | `3`                             |

### ⚠️ Important: publish_end_on Field

**The `publish_end_on` date MUST be set to a future date.** This is critical for the OpenSearch query to work.

**Why?** The query filters results using:

```
"range": { "publish_end_on": { "gt": "2026-08-12" } }
```

This means `publish_end_on` must be **greater than today** for the result to appear.

**What happens if it's nil?** The boosted content will be indexed but won't appear in search results because the date filter will exclude it.

---

## OpenSearch Index Details

### Index Naming

The BoostedContent index name is automatically generated using a timestamp pattern:

```
development-usasearch-elastic_boosted_contents-20260812095219529
```

**Format:** `{ENV_PREFIX}-usasearch-elastic_boosted_contents-{TIMESTAMP}`

You can check the current prefix in Rails console:

```ruby
Es::INDEX_PREFIX
ElasticBoostedContent.base_index_name
```

### Aliases

OpenSearch maintains two aliases for the index:

| Alias                                                   | Purpose                |
| ------------------------------------------------------- | ---------------------- |
| `development-usasearch-elastic_boosted_contents-reader` | Used for **searching** |
| `development-usasearch-elastic_boosted_contents-writer` | Used for **indexing**  |

These aliases are automatically managed - you don't need to interact with them directly.

---

## Getting Started Locally

### 1. Prerequisites

- Rails development environment running
- OpenSearch server running at `localhost:9300`
- Resque workers running (for background indexing)
- MySQL with `boosted_contents` table

### 2. Create Test BoostedContent Records

In Rails console:

```ruby
affiliate = Affiliate.find(1)  # or your test affiliate

affiliate.boosted_contents.create!(
  title: "Diabetes Information",
  url: "https://example.gov/diabetes",
  description: "Learn about diabetes prevention and management",
  status: "active",
  publish_start_on: Date.today,
  publish_end_on: Date.today + 1.year  # IMPORTANT: Future date!
)
```

**Don't forget keywords:**

```ruby
bc = affiliate.boosted_contents.last
bc.boosted_content_keywords.create!(value: "diabetes")
bc.boosted_content_keywords.create!(value: "blood sugar")
```

### 3. Create the OpenSearch Index

If it doesn't exist:

```bash
RAILS_ENV=development bundle exec rake 'usasearch:elasticsearch:recreate_index[BoostedContent]'
```

### 4. Index the Records

```bash
RAILS_ENV=development bundle exec rake 'usasearch:elasticsearch:index_all[BoostedContent]'
```

### 5. Commit the Index

In Rails console:

```ruby
ElasticBoostedContent.commit
```

### 6. Verify It Works

Test in Rails console:

```ruby
results = ElasticBoostedContent.search_for({
  q: 'diabetes',
  affiliate_id: 3,
  language: 'en'
})

puts "Total results: #{results.total}"
results.results.each { |r| puts "- #{r[:title]}" }
```

Or visit your local dev site and search for "diabetes" - you should see the boosted results at the top.

---

## Syncing Changes with OpenSearch

When you edit boosted content in the admin interface or database, it needs to be re-indexed into OpenSearch.

### Option 1: Manual Rake Task (Recommended)

For one-time syncs:

```bash
# Re-index all BoostedContent records
RAILS_ENV=development bundle exec rake 'usasearch:elasticsearch:index_all[BoostedContent]'

# Then refresh the index
RAILS_ENV=development bundle exec rails c
> ElasticBoostedContent.commit
> exit
```

### Option 2: Using Resque Workers

If Resque workers are running:

```bash
RAILS_ENV=development bundle exec rake 'usasearch:elasticsearch:resque_index_all[BoostedContent]'
```

The workers will process indexing jobs in the background.

### Option 3: Manual Indexing in Rails Console

```ruby
# Re-index all records
ElasticIndexer.index_all('BoostedContent')

# Commit changes
ElasticBoostedContent.commit
```

---

## Troubleshooting

### Problem: Boosted Content Not Appearing in Search

**Check these in order:**

1. **Verify `publish_end_on` is set:**

   ```ruby
   BoostedContent.where(id: your_id).pluck(:publish_end_on)
   ```

   Must show a future date, not `nil`.

2. **Verify status is "active":**

   ```ruby
   BoostedContent.where(id: your_id).pluck(:status)
   ```

3. **Verify records are in OpenSearch index:**

   ```ruby
   result = ElasticBoostedContent.client_reader.search(
     index: 'development-usasearch-elastic_boosted_contents-reader',
     body: { query: { match_all: {} } }
   )
   result['hits']['total']  # Should show > 0
   ```

4. **Check if records match the search query:**
   ```ruby
   results = ElasticBoostedContent.search_for({
     q: 'your_search_term',
     affiliate_id: 3,
     language: 'en',
     size: 10  # Show more results to debug
   })
   results.total
   ```

### Problem: Index Alias Misconfigured

**Error:** `no write index is defined for alias`

**Solution:** Recreate the index:

```bash
RAILS_ENV=development bundle exec rake 'usasearch:elasticsearch:recreate_index[BoostedContent]'
RAILS_ENV=development bundle exec rake 'usasearch:elasticsearch:index_all[BoostedContent]'
```

### Problem: Changes Not Showing After Editing

1. Hard refresh browser: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)
2. Restart Rails server if using `./bin/dev`
3. Re-run the indexing commands above

---

## Key Classes Reference

| Class                          | Purpose                                                  |
| ------------------------------ | -------------------------------------------------------- |
| `BoostedContent`               | Rails model for the MySQL table                          |
| `ElasticBoostedContent`        | OpenSearch index definition                              |
| `ElasticBoostedContentData`    | Transforms MySQL data to searchable format               |
| `ElasticBoostedContentQuery`   | Builds the search query for OpenSearch                   |
| `ElasticBoostedContentResults` | Wraps the search results                                 |
| `GovboxSet`                    | Orchestrates fetching boosted contents during search     |
| `Govboxable`                   | Mixin that delegates `boosted_contents` to `@govbox_set` |

---

## Display Configuration

### Maximum Results Displayed

By default, only **2 boosted results** are shown in the "Recommended" section.

To change this, edit `app/models/govbox_set.rb` line 182:

```ruby
# Show up to 5 results instead of 2
search_options = build_search_options(affiliate_id: @affiliate.id, size: 2, site_limits: @site_limits)
```

---

## Summary

BoostedContent is a powerful feature for promoting important content. Remember:

✅ **DO:**

- Set `publish_end_on` to a future date
- Run indexing after creating/editing records
- Test with `ElasticBoostedContent.search_for()`

❌ **DON'T:**

- Leave `publish_end_on` as `nil` (results won't appear)
- Forget to commit after indexing
- Edit HAML templates expecting changes (use React component)

For questions or issues, check the OpenSearch index directly or review the data flow diagram at the top of this guide.
