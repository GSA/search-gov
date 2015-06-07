SimpleCov.start 'rails' do
  add_filter '/vendor/'
  add_filter '/.bundler/'
  add_filter '/app/helpers/admin/'
  add_filter '/lib/i14y_collections.rb'
  merge_timeout 1800
end
