# Hack for compatibility with VCR
# See https://github.com/cucumber/cucumber-ruby/issues/1432
module Cucumber
  module RunningTestCase
    class TestCase < SimpleDelegator
      def feature
        string = File.read(location.file)
        document = ::Gherkin::Parser.new.parse(string)
        document.feature
      end
    end
  end
end

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
  travel_back
end
