require 'spec_helper'

describe HostedAzureImageEngine do
  let(:azure_image_url) do
    "#{HostedAzureImageEngine::API_HOST}#{HostedAzureImageEngine::API_ENDPOINT}"
  end

  describe 'api namespacing' do
    it 'uses the AzureCompositeEngine namespace' do
      described_class.api_namespace.should eq(AzureCompositeEngine::NAMESPACE)
    end
  end

  describe '#execute_query' do
    context 'when image results are present' do
      let(:image_search) do
        described_class.new language: 'en',
                            offset: 0,
                            per_page: 10,
                            query: 'agncy (site:nasa.gov)'
      end

      let(:search_response) { image_search.execute_query }

      it 'sets spelling suggestion' do
        expect(search_response.spelling_suggestion).to eq('agency')
      end

      it_should_behave_like "an image search"
    end

    context 'when next page results are not present' do
      let(:engine) do
        described_class.new language: 'en',
                            offset: 998,
                            per_page: 5,
                            query: 'azure image no next'
      end

      before do
        no_next_result = Rails.root.join('spec/fixtures/json/azure/image_spell/no_next.json').read
        stub_request(:get, /#{azure_image_url}.*azure image no next/).
          to_return( status: 200, body: no_next_result )
      end

      subject(:response) { engine.execute_query }

      it 'populates results' do
        expect(response.results.count).to eq(2)
      end

      it 'sets total, start record and end record' do
        expect(response.total).to eq(1000)
        expect(response.start_record).to eq(999)
        expect(response.end_record).to eq(1000)
      end
    end

    context 'when image results are not present' do
      let(:engine) do
        described_class.new language: 'en',
                            offset: 0,
                            per_page: 5,
                            query: 'agency (site:noresults.nasa.gov)'
      end

      subject(:response) { engine.execute_query }

      it 'sets total' do
        expect(response.total).to eq(0)
      end
    end
  end
end
