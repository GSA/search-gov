require 'spec_helper'
require 'rack/mock'

describe RejectInvalidRequestUri do
  context 'when processing a request with invalid URI' do
    let(:app) { double('app') }
    let(:middleware) { RejectInvalidRequestUri.new(app) }
    let(:env) { { 'REQUEST_URI' => "/search?query=\xC0" } }

    it 'should return with status 400' do
      status, header, body = middleware.call env
      expect(status).to eq(400)
    end
  end
end
