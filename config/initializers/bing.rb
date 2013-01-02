BING_API_SITE = 'http://api.bing.net'
BING_API_ENDPOINT = '/json.aspx'
BING_USER_AGENT = 'USASearch'
BING_CACHE_DURATION_IN_SECONDS = 60 * 60 * 6

$bing_api_connection = Faraday.new BING_API_SITE do |conn|
  cache_dir = File.join(Rails.root, 'tmp', 'cache')
  conn.request :json
  conn.response :rashify
  conn.response :json
  conn.response :caching do
    ActiveSupport::Cache::FileStore.new cache_dir, :namespace => 'bing_api', :expires_in => BING_CACHE_DURATION_IN_SECONDS
  end
  #conn.use :instrumentation
  conn.adapter :net_http_persistent
end

ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = end_time - start_time
  $stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
end