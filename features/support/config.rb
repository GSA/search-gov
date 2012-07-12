Before do
  Sunspot.remove_all!
  ActiveRecord::Fixtures.reset_cache
  ActiveRecord::Fixtures.create_fixtures("spec/fixtures", ['users', 'agencies', 'affiliates'])
end