module I14yCollections
  API_ENDPOINT = "/api/v1/collections"

  def self.establish_connection!
    @i14y_api_connection = Faraday.new host do |conn|
      conn.request :json
      conn.response :mashify
      conn.response :json
      conn.use :instrumentation
      conn.adapter :net_http_persistent
      conn.basic_auth(admin_user, admin_password)
    end
  end

  def self.create(handle, token)
    params = { handle: handle, token: token }
    response = @i14y_api_connection.post API_ENDPOINT, params
    response.body
  end

  def self.delete(handle)
    response = @i14y_api_connection.delete "#{API_ENDPOINT}/#{handle}"
    response.body
  end

  def self.search(params)
    response = @i14y_api_connection.get "#{API_ENDPOINT}/search", params
    response.body
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

  private

  def self.yaml
    @@yaml ||= YAML.load_file("#{Rails.root}/config/i14y.yml")[Rails.env]
  end

end

I14yCollections.establish_connection!