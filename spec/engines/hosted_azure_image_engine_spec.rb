require 'spec_helper'

describe HostedAzureImageEngine do
  describe 'api namespacing' do
    it 'uses the AzureCompositeEngine namespace' do
      described_class.api_namespace.should eq(AzureCompositeEngine::NAMESPACE)
    end
  end

  describe '#execute_query' do
    context 'when image results are present' do
      let(:engine) do
        described_class.new language: 'en',
                            offset: 0,
                            per_page: 5,
                            query: 'agncy (site:nasa.gov)'
      end

      subject(:response) { engine.execute_query }

      it 'sets results' do
        expect(response.results.count).to eq(5)
      end

      it 'sets total, start record and end record' do
        expect(response.total).to eq(3730)
        expect(response.start_record).to eq(1)
        expect(response.end_record).to eq(5)
      end

      it 'sets result with title, URL and thumbnail URL' do
        result = response.results.first
        expect(result.title).to eq('We lead the effort to make NASA a model Agency for diversity and')
        expect(result.url).to eq('http://odeo.hq.nasa.gov/')
        expect(result.thumbnail.url).to eq('http://ts1.mm.bing.net/th?id=JN.eSAGMeI063nxC6Ycyt4tdg&pid=15.1')
        expect(result['Thumbnail']['Url']).to eq('http://ts1.mm.bing.net/th?id=JN.eSAGMeI063nxC6Ycyt4tdg&pid=15.1')
      end

      it 'sets spelling suggestion' do
        expect(response.spelling_suggestion).to eq('agency')
      end
    end

    context 'when next page results are not present' do
      let(:engine) do
        described_class.new language: 'en',
                            offset: 998,
                            per_page: 5,
                            query: 'agncy (site:nasa.gov)'
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
