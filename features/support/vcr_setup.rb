VCR.configure do |config|
  config.cassette_library_dir = 'features/cassettes'
  config.hook_into :faraday

  #ignore elasticsearch requests
  config.ignore_request do |request|
    URI(request.uri).port == 9200
  end

  config.default_cassette_options = { re_record_interval: 1.month }
end

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end
