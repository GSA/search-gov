SimpleCov.start 'rails' do
  add_filter '/vendor/'
  add_filter '/.bundler/'
  add_filter '/app/helpers/admin/'
  merge_timeout 1800
end
