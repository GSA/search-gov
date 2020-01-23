Before do |scenario|
  ActiveRecord::FixtureSet.reset_cache
  ActiveRecord::FixtureSet.create_fixtures('spec/fixtures', %w(users federal_register_agencies agencies affiliates twitter_profiles memberships rss_feeds rss_feed_urls hints languages))
end

Around do |scenario, block|
  VCR.use_cassette("#{scenario.feature.name}/#{scenario.name}") do
    block.call
  end
end

After do |scenario|
  ScenarioStatusTracker.success = false if scenario.failed?
  Timecop.return
end
