require 'spec_helper'

describe CachedSearchApiConnectionResponse do
  let(:cached_response) { described_class.new(:response, :cache_name) }

  it 'returns a response and cache namespace' do
    expect(cached_response).to respond_to(:response)
    expect(cached_response).to respond_to(:cache_namespace)
  end
end