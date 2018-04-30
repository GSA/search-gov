require_relative '../../spec/support/shared_vcr_setup.rb'

VCR.configure do |config|
  config.cassette_library_dir = 'features/vcr_cassettes'
  config.allow_http_connections_when_no_cassette = true

  #Capybara: http://stackoverflow.com/a/6120205/1020168
  config.ignore_request do |request|
    URI(request.uri).request_uri == "/__identify__"
  end
end
