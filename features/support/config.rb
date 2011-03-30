Before do
  Sunspot.remove_all!
  Fixtures.reset_cache
  Fixtures.create_fixtures("spec/fixtures", ['users', 'agencies', 'affiliates', 'affiliate_templates', 'affiliate_broadcasts'])
end
