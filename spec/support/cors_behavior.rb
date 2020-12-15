# frozen_string_literal: true

shared_examples_for 'a request with CORS support' do |req_method|
  context 'when the request originates from an external domain' do
    let(:req_headers) do
      {
        'HTTP_ORIGIN' => 'http://cors.example.com',
        'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'Content-Type',
        'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => req_method
      }
    end

    it 'responds to pre-flight options requests' do
      process :options, endpoint, params: valid_params, headers: req_headers
      expect(headers['Access-Control-Allow-Methods']).to match(/#{req_method}/)
    end

    it 'returns the Access-Control-Allow-Origin header' do
      make_request
      expect(headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end
end
