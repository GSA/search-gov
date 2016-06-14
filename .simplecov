SimpleCov.start 'rails' do
  add_filter '/vendor/'
  add_filter '/.bundler/'
  add_filter '/app/helpers/admin/'
  add_filter '/lib/i14y_collections.rb'
  add_group 'Engines', 'app/engines'
  add_group 'API', 'app/api'
  add_group 'Concerns', 'app/concerns'
  merge_timeout 1800
end
