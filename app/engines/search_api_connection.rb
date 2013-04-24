class SearchApiConnection
  attr_reader :connection

  delegate :get, :to => :connection

  def initialize(name, site, cache_duration = 60 * 60 * 6)
    @connection = Faraday.new site do |conn|
      cache_dir = File.join(Rails.root, 'tmp', 'cache')
      conn.request :json
      conn.response :rashify
      conn.response :json
      conn.response :caching do
        ActiveSupport::Cache::FileStore.new cache_dir, :namespace => name, :expires_in => cache_duration
      end
      conn.headers[:user_agent] = 'USASearch'
      #conn.use :instrumentation
      conn.adapter :net_http_persistent
    end
  end
end