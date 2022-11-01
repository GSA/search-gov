require_relative '../../spec/support/shared_vcr_setup.rb'

VCR.configure do |config|
  config.cassette_library_dir = 'features/vcr_cassettes'
  config.allow_http_connections_when_no_cassette = true
end
