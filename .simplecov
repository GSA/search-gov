SimpleCov.start 'rails' do
  add_filter '/vendor/'
  add_filter '/.bundler/'
  merge_timeout 1800
end
