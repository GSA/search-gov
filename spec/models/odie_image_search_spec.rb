# frozen_string_literal: true

describe OdieImageSearch do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:query) { 'obama' }
  let(:image_search) { described_class.new(query: query, affiliate: affiliate) }
  let(:search_engine_response) do
    SearchEngineResponse.new do |search_response|
      search_response.total = 2
      search_response.start_record = 1
      search_response.results = [Hashie::Mash::Rash.new(title: 'President Obama walks the Obama daughters to school', url: 'http://url1', thumbnail_url: 'http://thumbnailurl1'), Hashie::Mash::Rash.new(title: 'POTUS gets in car.', url: 'http://url2', thumbnail_url: 'http://thumbnailurl2')]
      search_response.end_record = 2
    end
  end

  before do
    oasis_search = double(OasisSearch)
    allow(OasisSearch).to receive(:new).and_return oasis_search
    allow(oasis_search).to receive(:execute_query).and_return search_engine_response
  end

  describe '.search' do
    before do
      allow(Rails.logger).to receive(:info)
      image_search.run
    end

    it 'should retrieve photos from Oasis API endpoint' do
      expect(image_search.results.first['title']).to eq('President Obama walks the Obama daughters to school')
      expect(image_search.results.last['title']).to eq('POTUS gets in car.')
      expect(image_search.total).to eq(2)
    end

    it 'logs the query JSON' do
      expect(Rails.logger).to have_received(:info).with(/"query":"obama"/) 
    end

    context 'when the query includes sensitive data' do
      let(:query) { '123-45-6789' }

      it 'redacts the data' do
        expect(Rails.logger).not_to have_received(:info).with(/123-45-6789/)
      end
    end
  end

  describe '.cache_key' do
    it 'should output a key based on the query, affiliate id, and page parameters' do
      expect(described_class.new(query: 'element', affiliate: affiliate, page: 4).cache_key).to eq("oasis_image:element:#{affiliate.id}:4:10")
    end
  end

  describe 'new' do
    context 'when affiliate has MRSS feeds' do
      before do
        affiliate.flickr_profiles.delete_all
        affiliate.rss_feeds << rss_feeds(:media_feed)
      end

      it 'should create an OasisSearch with the MRSS feed names' do
        expect(OasisSearch).to receive(:new).with(query: 'element', per_page: 10, offset: 0, mrss_names: ['13'],
                                              flickr_users: [], flickr_groups: [])
        described_class.new(query: 'element', affiliate: affiliate)
      end
    end
  end
end
