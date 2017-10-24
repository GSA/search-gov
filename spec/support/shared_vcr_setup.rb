VCR.configure do |config|
  config.hook_into :webmock
  config.default_cassette_options = { record: :new_episodes, re_record_interval: 2.months }

  config.ignore_hosts 'api.keen.io', 'example.com', 'codeclimate.com'
  config.ignore_request do |request|
    /amazonaws|codeclimate.com/ ===  URI(request.uri).host
  end

  config.ignore_request { |request| URI(request.uri).port == 9200 } #Elasticsearch

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  #For future debugging reference:
  #config.debug_logger = STDOUT
end
