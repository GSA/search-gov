Before do
  Sunspot.remove_all!
  ActiveRecord::Fixtures.reset_cache
  ActiveRecord::Fixtures.create_fixtures('spec/fixtures', %w(users agencies affiliates))
end

After('@featured_collection') do
  FeaturedCollection.destroy_all
end
