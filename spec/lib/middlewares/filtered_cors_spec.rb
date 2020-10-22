# frozen_string_literal: true

require 'spec_helper'
require 'rack/mock'

describe FilteredCORS do
  context 'when path_info is in the CORS supported list' do
    it 'assigns Access-Control-Allow-Origin' do
      paths = %w[/api/search /api/v2/click /api/v2/search /sayt]

      paths.each do |path|
        test_body = '{"bar":"foo"}'.freeze
        app = lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] }

        request = Rack::MockRequest.env_for(path, params: 'foo=bar')
        headers = described_class.new(app).call(request)[1]
        expect(headers['Access-Control-Allow-Origin']).to  eq('*')
      end
    end
  end

  context 'when path_info is not in the CORS supported list' do
    it 'does not assign Access-Control-Allow-Origin' do
      path = '/search'
      test_body = '{"bar":"foo"}'.freeze
      app = lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] }

      request = Rack::MockRequest.env_for(path, params: 'foo=bar')
      headers = described_class.new(app).call(request)[1]
      expect(headers.keys).not_to include('Access-Control-Allow-Origin')
    end
  end
end
