class SearchApiConnection
  attr_reader :connection

  delegate :get, :to => :connection

  def initialize(name, site, cache_duration = 60 * 60 * 6)
    @connection = Faraday.new site do |conn|
      conn.request :json
      conn.response :rashify
      conn.response :json
      conn.response :caching do
        ActiveSupport::Cache::FileStore.new File.join(Rails.root, 'tmp', 'api_cache'), :namespace => name, :expires_in => cache_duration
      end unless cache_duration.zero?
      conn.headers[:user_agent] = 'USASearch'
      #conn.use :instrumentation
      conn.adapter :net_http_persistent
      ExternalFaraday.set_connection_options conn
    end
  end
end
