Before do
  ActiveRecord::Fixtures.reset_cache
  ActiveRecord::Fixtures.create_fixtures('spec/fixtures', %w(users agencies affiliates statuses tags twitter_profiles memberships rss_feeds rss_feed_urls))
end
