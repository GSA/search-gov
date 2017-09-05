module I14y
  def self.establish_connection!(user: admin_user, password: admin_password)
    Faraday.new host do |conn|
      conn.request :json
      conn.response :mashify
      conn.response :json
      conn.use :instrumentation
      conn.adapter :net_http_persistent
      conn.basic_auth(user, password)
    end
  end

  def self.host
    yaml['host']
  end

  def self.admin_user
    yaml['admin_user']
  end

  def self.admin_password
    yaml['admin_password']
  end

  def self.yaml
    @@yaml ||= YAML.load_file("#{Rails.root}/config/i14y.yml")[Rails.env]
  end
end
