class RequestStub
  def initialize(url, response_directory, stubs)
    @url = url
    @response_directory = response_directory
    @stub = stubs
  end

  def stub_get_request(params)
    stub_url = "#{@url}?#{params.to_param}"
    @stub.get(stub_url) { yield }
  end

  def raw_response(filename)
    Rails.root.join("#{@response_directory}#{filename}").read
  end
end
