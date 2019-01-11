module I14yCollections
  API_ENDPOINT = "/api/v1/collections"

  def self.i14y_connection
    @i14y_connection ||= I14y.establish_connection!
  end

  def self.create(handle, token)
    params = { handle: handle, token: token }
    response = i14y_connection.post API_ENDPOINT, params
    response.body
  end

  def self.delete(handle)
    response = i14y_connection.delete "#{API_ENDPOINT}/#{handle}"
    response.body
  end

  def self.get(handle)
    response = i14y_connection.get "#{API_ENDPOINT}/#{handle}"
    response.body
  end

  def self.search(params)
    response = i14y_connection.get "#{API_ENDPOINT}/search", params
    response.body
  end
end
