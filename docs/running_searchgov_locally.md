### Running Search-gov locally:

Use these steps to stand up a local environment that mirrors production. They back up your current database, load the production schema, seed sample data (affiliate, domains, best bets, and so on), and index into OpenSearch. These steps let you verify changes locally before merging a PR to production. You can also follow the same steps when you need a clean local development setup from scratch.

#### Step 1. Backup existing database to load it later by running from within your mysql container

```bash
mysqldump usasearch_development > backup.sql
```

#### Step 2. Switch to production branch, drop your database and load the production schema

```bash
git checkout production
bundle install
bundle exec rails db:drop db:create db:schema:load
```

#### Step 3. Load locale

```ruby
load Rails.root.join("db/seeds/language.rb")
```

#### Step 4. Create Affiliate

```ruby
va = Affiliate.create!(
  name: "va",
  display_name: "va",
  website: "https://www.va.gov/",
  favicon_url: "http://www.va.gov/img/design/icons/favicon.ico",
  search_engine: "legacy_opensearch",
  default_search_label: "Everything",
  get_results_from_all_domains: true,
  locale: "en"
)
```

#### Step 5. Add Domain

```ruby
va.site_domains.create!(domain: "www.va.gov", site_name: "www.va.gov")
```

#### Step 6. Add Collection + URL prefixes

```ruby
collection = va.document_collections.create!(
  name: "Social media",
  url_prefixes_attributes: [
    { prefix: "http://www.facebook.com/" },
    { prefix: "http://www.instagram.com/" }
  ]
)
```

#### Step 7. Add Best bets (+ keywords)

```ruby
va.boosted_contents.create!(
  title: "diabetes",
  url: "http://www.google.com",
  description: "google diabetes",
  status: "active",
  publish_start_on: "2026-08-12",
  publish_end_on: "2027-08-12",
  boosted_content_keywords_attributes: [
    { value: "diabetes google social-media" }
  ]
)

va.boosted_contents.create!(
  title: "yahoo diabetes",
  url: "http://www.yahoo.com",
  description: "diabetes",
  status: "active",
  publish_start_on: "2026-08-12",
  publish_end_on: "2027-08-12",
  boosted_content_keywords_attributes: [
    { value: "diabetes yahoo social-media" }
  ]
)

va.boosted_contents.create!(
  title: "facebook diabetes",
  url: "https://www.va.gov/chicago-health-care/events/82938/",
  description: "facebook diabetes",
  status: "active",
  publish_start_on: "2026-08-12",
  publish_end_on: "2027-08-12",
  boosted_content_keywords_attributes: [
    { value: "diabetes facebook social-media" }
  ]
)
```

#### Step 8. With OpenSearch running, start the worker and add the domain for indexing

```bash
QUEUE=* VERBOSE=true bundle exec rake environment resque:work
```

```ruby
SearchgovDomain.create!(domain: "www.va.gov")
```

#### Step 9. Verify index is getting populated

In OpenSearch Dashboard ([http://localhost:5701/app/dev_tools#/console](http://localhost:5701/app/dev_tools#/console)); run `GET _cat/indices?v` and you should see `docs.count` for `development-i14y-documents-searchgov-legacy` increasing.
