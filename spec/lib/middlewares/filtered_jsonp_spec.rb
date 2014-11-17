require 'spec_helper'

require 'rack/mock'

describe FilteredJSONP do
  context 'when path_info is in the JSONP supported list' do
    it 'wrap the response body in the Javascript callback' do
      paths = %w(/api/search /sayt)

      paths.each do |path|
        test_body = '{"bar":"foo"}'.freeze
        callback = 'foo'
        app = lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] }

        request = Rack::MockRequest.env_for(path, params: "foo=bar&callback=#{callback}")
        body = described_class.new(app).call(request).last
        expect(body).to  eq(["/**/#{callback}(#{test_body})"])
      end
    end
  end

  context 'when path_info is not in the JSONP supported list' do
    it 'ignores the callback' do
      path = '/api/v2/search'
      test_body = '{"bar":"foo"}'.freeze
      callback = 'foo'
      app = lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] }

      request = Rack::MockRequest.env_for(path, params: "foo=bar&callback=#{callback}")
      body = described_class.new(app).call(request).last
      expect(body).to eq([test_body])
    end
  end
end
