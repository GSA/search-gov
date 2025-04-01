require 'spec_helper'

describe CachedSearchApiConnectionResponse do
  let(:reponse) { described_class.new(:response, :cache_name) }

  it 'returns a response and cache namespace' do
    expect(reponse).to respond_to(:response)
    expect(reponse).to respond_to(:cache_namespace)
  end
end
