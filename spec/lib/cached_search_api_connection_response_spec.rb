require 'spec_helper'

describe CachedSearchApiConnectionResponse do
  let(:response) { described_class.new(:response, :cache_name) }

  it 'returns a response and cache namespace' do
    expect(response).to respond_to(:response)
    expect(response).to respond_to(:cache_namespace)
  end
end
