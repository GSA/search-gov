require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true

  config.default_cassette_options = { re_record_interval: 1.month, record: :new_episodes }

  config.ignore_request do |request|
    /amazonaws|codeclimate.com/ ===  URI(request.uri).host
  end
  config.ignore_hosts 'example.com', 'codeclimate.com'

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  #For future debugging reference:
  #config.debug_logger = STDOUT
end
