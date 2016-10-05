VCR.configure do |config|
  config.cassette_library_dir = 'features/vcr_cassettes'
  config.hook_into :faraday

  config.default_cassette_options = { record: :new_episodes, re_record_interval: 1.month }

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  config.ignore_request do |request|
    /amazonaws/ ===  URI(request.uri).host
  end

  config.ignore_request { |request| URI(request.uri).port == 9200 } #Elasticsearch

  config.ignore_hosts 'api.keen.io', 'codeclimate.com'

  #For future debugging reference:
  #config.debug_logger = STDOUT
end

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end
