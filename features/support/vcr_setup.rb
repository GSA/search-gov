VCR.configure do |config|
  config.cassette_library_dir = 'features/vcr_cassettes'
  config.hook_into :faraday
  config.ignore_localhost = true

  config.default_cassette_options = { re_record_interval: 1.month }

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  config.ignore_request do |request|
    /rackspacecloud|clouddrive/ ===  URI(request.uri).host
  end

  config.ignore_host 'api.keen.io'

  #For future debugging reference:
  #config.debug_logger = STDOUT
end

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end
