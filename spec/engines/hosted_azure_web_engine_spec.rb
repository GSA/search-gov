require 'spec_helper'

describe HostedAzureWebEngine do
  let(:azure_web_url) { "#{AzureWebEngine::API_HOST}#{AzureWebEngine::API_ENDPOINT}" }

  describe 'api namespacing' do
    it 'uses the AzureEngine namespace' do
      described_class.api_namespace.should eq(AzureEngine::NAMESPACE)
    end
  end

  describe '#execute_query' do
    context 'when response _next is present' do
      let(:engine) do
        HostedAzureWebEngine.new enable_highlighting: true,
                                 language: 'en',
                                 offset: 0,
                                 per_page: 20,
                                 query: 'food nutrition (site:usa.gov)'
      end

      subject(:response) { engine.execute_query }

      it 'sets results' do
        expect(response.results.count).to eq(20)
      end

      it 'sets fake total' do
        expect(response.total).to eq(21)
      end

      it 'highlights title and description' do
        result = response.results.first
        expect(result.title).to match(/\ue000.+\ue001/)
        expect(result.content).to match(/\ue000.+\ue001/)
        expect(result.unescaped_url).to match(URI.regexp)
      end
    end

    context 'when response _next is not present' do
      let(:engine) do
        HostedAzureWebEngine.new enable_highlighting: true,
                                 language: 'en',
                                 offset: 0,
                                 per_page: 20,
                                 query: 'azure web no next'
      end

      before do
        no_next_result = Rails.root.join('spec/fixtures/json/azure/web_only/no_next.json').read
        stub_request(:get, /#{azure_web_url}.*azure web no next/)
          .to_return( status: 200, body: no_next_result )
      end

      subject(:response) { engine.execute_query }

      it 'sets total' do
        expect(response.total).to eq(12)
      end
    end

    context 'when there are no results' do
      let(:engine) do
        HostedAzureWebEngine.new enable_highlighting: true,
                                 language: 'en',
                                 offset: 0,
                                 per_page: 20,
                                 query: 'mango smoothie (site:usa.gov)'
      end

      subject(:response) { engine.execute_query }

      it 'sets total' do
        expect(response.total).to eq(0)
      end
    end
  end
end
