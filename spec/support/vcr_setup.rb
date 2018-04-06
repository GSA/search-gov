require 'vcr'
# See spec/support/shared_vcr_setup.rb for configuration settings
# shared with cucumber

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.configure_rspec_metadata!
  config.default_cassette_options[:re_record_interval] = 2.months
end
