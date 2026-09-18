# frozen_string_literal: true

describe FaradayMiddleware::Rashify do
  let(:connection) do
    Faraday.new('http://example.test') do |conn|
      conn.response(:rashify)
      conn.response(:json, content_type: nil)
      conn.adapter(:net_http_persistent)
    end
  end

  it 'turns a JSON body into a Hashie rash when Content-Type is missing' do
    stub_request(:get, 'http://example.test/search').
      to_return(status: 200, body: { foo: 'bar' }.to_json)

    expect(connection.get('/search').body.foo).to eq('bar')
  end
end
