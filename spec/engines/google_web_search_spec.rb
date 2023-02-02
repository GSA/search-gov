require 'spec_helper'

describe GoogleWebSearch do

  it_behaves_like 'a web search engine'

  describe '.new for GoogleWebSearch' do
    it 'should assign start' do
      expect(described_class.new(query: 'gov', offset: 15).start).to eq(16)
    end

    it 'uses rate limited api connection by default' do
      search = described_class.new(query: 'gov')
      expect(search.api_connection).to be_an_instance_of(RateLimitedSearchApiConnection)
    end

    context 'when only required search params are passed in' do
      let(:minimum_search) { described_class.new(query: 'taxes') }

      it 'should set appropriate defaults' do
        expect(minimum_search.query).to eq('taxes')
        expect(minimum_search.filter_level).to eq('medium')
      end
    end

    context 'when all search params are passed in' do
      let(:fully_specified_search) { described_class.new(query: 'taxes', offset: 11, filter: 2) }

      it 'should set appropriate values from params' do
        expect(fully_specified_search.query).to eq('taxes')
        expect(fully_specified_search.offset).to eq(11)
        expect(fully_specified_search.filter_level).to eq('high')
      end
    end

    describe 'adult content filters' do
      context 'when a valid filter parameter is present' do
        it 'should set the filter_level parameter to the Google-specific level' do
          expect(described_class.new(query: 'taxes', filter: 0).filter_level).to eq('off')
          expect(described_class.new(query: 'taxes', filter: 1).filter_level).to eq('medium')
          expect(described_class.new(query: 'taxes', filter: 2).filter_level).to eq('high')
        end
      end

      context 'when the filter parameter is blank/invalid' do
        it 'should set the filter_level parameter to the default value (medium)' do
          expect(described_class.new(query: 'taxes', filter: '').filter_level).to eq('medium')
          expect(described_class.new(query: 'taxes', filter: 'whatevs').filter_level).to eq('medium')
        end
      end
    end
  end

  context 'when affiliate-specific google CX key are set' do
    let(:web_search) do
      described_class.new(query: 'google customcx', google_cx: '1234567890.abc', google_key: 'some_key')
    end

    before do
      google_api_url = "#{GoogleSearch::API_HOST}#{GoogleSearch::API_ENDPOINT}"
      google_customcx = Rails.root.join('spec/fixtures/json/google/web_search/custom_cx.json').read
      stub_request(:get, /#{google_api_url}.*google customcx/).
        to_return( status: 200, body: google_customcx )
    end

    it 'should use that for the Google API call' do
      response = web_search.execute_query
      first = response.results.first
      expect(first.title).to eq('Using custom google CX')
    end

    it 'uses non rate limited api connection' do
      expect(web_search.api_connection).to be_an_instance_of(CachedSearchApiConnection)
    end
  end

end
