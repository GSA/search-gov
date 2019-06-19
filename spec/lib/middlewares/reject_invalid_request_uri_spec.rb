require 'spec_helper'
require 'rack/mock'

describe RejectInvalidRequestUri do
  context 'when processing a request with invalid URI' do
    let(:app) { double('app') }
    let(:middleware) { RejectInvalidRequestUri.new(app) }
    let(:env) { { 'REQUEST_URI' => "/search?query=\xC0" } }
    let(:response) { middleware.call(env) }
    let(:status) { response.first }

    it 'returns a 400 status' do
      expect(status).to eq(400)
    end

    context 'when invalid arguments are passed' do
      before { allow(CGI).to receive(:unescape).and_raise(ArgumentError) }

      it 'returns a 400 status' do
        expect(status).to eq(400)
      end
    end
  end
end
