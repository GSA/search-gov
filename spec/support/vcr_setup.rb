require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true

  config.ignore_request do |request|
    /rackspacecloud|clouddrive/ ===  URI(request.uri).host
  end
  config.ignore_hosts 'example.com'

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  #For future debugging reference:
  #config.debug_logger = STDOUT
end
