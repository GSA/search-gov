require 'vcr'
# See spec/support/shared_vcr_setup.rb for configuration settings
# shared with cucumber

VCR.configure do |config|
  config.ignore_hosts 'example.com', 'codeclimate.com'
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.configure_rspec_metadata!
end
