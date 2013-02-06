SimpleCov.start 'rails' do
  add_filter '/vendor/'
  add_filter '/.bundler/'
  add_filter '/lib/middlewares/reject_invalid_request_uri.rb'
  merge_timeout 1800
end
