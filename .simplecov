SimpleCov.start 'rails' do
  add_filter '/vendor/'
  add_filter '/.bundler/'
  add_filter '/app/helpers/admin/'
  add_filter '/app/engines/search_api_connection.rb'
  merge_timeout 1800
end
