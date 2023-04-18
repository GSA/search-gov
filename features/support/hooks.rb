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
  ActiveRecord::FixtureSet.create_fixtures('spec/fixtures', %w(users federal_register_agencies agencies affiliates memberships rss_feeds rss_feed_urls hints languages))
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

# Run axe tests on scenarios with @a11y tag, but not @a11y_wip tag
After('@a11y and not @a11y_wip') do
  step 'the page should be axe clean according to: section508, wcag2aa'
end
