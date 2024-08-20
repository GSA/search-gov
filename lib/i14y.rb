# frozen_string_literal: true

# I14y connection configuration
module I14y
  def self.establish_connection!(user: admin_user, password: admin_password)
    Faraday.new(host) do |conn|
      conn.response(:logger)
      conn.request(:json)
      conn.response(:mashify)
      conn.response(:json)
      conn.use(:instrumentation)
      conn.adapter(:net_http_persistent)
      conn.basic_auth(user, password)
    end
  end

  def self.host
    ENV['I14Y_HOST']
  end

  def self.admin_user
    ENV['I14Y_ADMIN_USER']
  end

  def self.admin_password
    ENV['I14Y_ADMIN_PASSWORD']
  end

  def self.cached_connection
    conn = CachedSearchApiConnection.new('i14y', host, I14Y_CACHE_DURATION)
    conn.tap { |conn| conn.basic_auth(admin_user, admin_password) }
  end
end
