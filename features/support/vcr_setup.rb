VCR.configure do |config|
  config.cassette_library_dir = 'features/vcr_cassettes'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true

  config.default_cassette_options = { record: :new_episodes, re_record_interval: 2.months }

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  config.ignore_request do |request|
    /amazonaws|search.digitalgov.gov|codeclimate.com/ ===  URI(request.uri).host
  end

  config.ignore_request { |request| URI(request.uri).port == 9200 } #Elasticsearch

  #Capybara: http://stackoverflow.com/a/6120205/1020168
  config.ignore_request do |request|
    URI(request.uri).request_uri == "/__identify__"
  end

  config.ignore_hosts 'api.keen.io', 'codeclimate.com'

  #For future debugging reference:
  #config.debug_logger = STDOUT
end

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end
