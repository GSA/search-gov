require 'spec_helper'

describe ApiGoogleDocsSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:api_key) {  GoogleSearch::API_KEY }
  let(:cx) { GoogleSearch::SEARCH_CX }
  let(:search_params) do
    { affiliate: affiliate,
      api_key: api_key,
      cx: cx,
      enable_highlighting: true,
      limit: 10,
      next_offset_within_limit: true,
      offset: 0,
      query: 'ira' }
  end

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  describe '#new' do
    before do
      affiliate.site_domains.create!(domain: 'whitehouse.gov')
      affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
    end

    it 'initializes GoogleWebSearch' do
      expect(GoogleWebSearch).to receive(:new).
        with(enable_highlighting: false,
             language: 'en',
             next_offset_within_limit: true,
             offset: 10,
             password: 'my_api_key',
             query: 'gov -site:kids.usa.gov site:whitehouse.gov OR site:usa.gov')

      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          language: 'en',
                          enable_highlighting: false,
                          dc: 1,
                          next_offset_within_limit: true,
                          offset: 10,
                          query: 'gov'
    end
  end

  describe '#run' do
    context 'when offset is 0' do
      it 'initializes GovboxSet' do
        highlighting_options = {
          highlighting: true,
          pre_tags: ["\ue000"],
          post_tags: ["\ue001"]
        }

        expect(GovboxSet).to receive(:new).with(
          'healthy snack',
          affiliate,
          nil,
          highlighting_options)

        described_class.new(affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'healthy snack').run
      end
    end

    context 'when offset is not 0' do
      it 'does not initialize GovboxSet' do
        expect(GovboxSet).not_to receive(:new)

        described_class.new(affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 888,
                            query: 'ira').run
      end
    end

    context 'when highlighting is enabled' do
      subject(:search) { described_class.new search_params }

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and content' do
        expect(search.results.map(&:title).compact).to include(match(/\ue000.+\ue001/))
        expect(search.results.map(&:content).compact).to include(match(/\ue000.+\ue001/))
      end

      it 'includes urls' do
        expect(search.results.map(&:unescaped_url).compact).to include(match(URI.regexp))
      end

      its(:next_offset) { is_expected.to eq(10) }
      its(:modules) { is_expected.to include('GWEB') }
    end

    context 'when highlighting is disabled' do
      subject(:search) do
        described_class.new search_params.merge(enable_highlighting: false)
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'return non highlighted title and description' do
        result = search.results.first
        expect(result.title).to_not match(/\ue000.+\ue001/)
        expect(result.content).to_not match(/\ue000.+\ue001/)
      end

      its(:next_offset) { is_expected.to eq(10) }
      its(:modules) { is_expected.to include('GWEB') }
    end

    context 'when response _next is not present' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'WHARRGARBL'
      end

      before do
        affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
        affiliate.excluded_domains.create!(domain: 'www.usa.gov')
        search.run
      end

      its(:next_offset) { should be_nil }
    end

    context 'when the site locale is es' do
      let(:affiliate) { affiliates(:spanish_affiliate) }
      let(:search)  { described_class.new search_params.merge(query: 'casa blanca') }

      before do
        I18n.locale = :es
        search.run
      end

      after do
        I18n.locale = :en
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and content' do
        expect(search.results.map(&:title).compact).to include(match(/\ue000.+\ue001/))
        expect(search.results.map(&:content).compact).to include(match(/\ue000.+\ue001/))
      end

      it 'includes urls' do
        expect(search.results.map(&:unescaped_url).compact).to include(match(URI.regexp))
      end
    end

    context 'when Google response contains empty results' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            cx: 'my_cx',
                            enable_highlighting: true,
                            limit: 10,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'WHARRGARBL'
      end

      before { search.run }

      its(:results) { should be_empty }
      its(:modules) { should_not include('GWEB') }
    end
  end

  describe '#as_json' do
    subject(:search) do
      described_class.new search_params.merge(query: 'ira')
    end

    before {
      I18n.locale = :en
      search.run
    }

    it 'returns results' do
      expect(search.as_json[:docs][:results].count).to be > 1
    end

    it 'returns a formatted query' do
      expect(search.as_json[:query]).to eq('ira')
    end

    it 'highlights title and content' do
      expect(search.results.map(&:title).compact).to include(match(/\ue000.+\ue001/))
      expect(search.results.map(&:content).compact).to include(match(/\ue000.+\ue001/))
    end

    it 'includes urls' do
      expect(search.results.map(&:unescaped_url).compact).to include(match(URI.regexp))
    end
  end

  describe '#as_json with advanced query operators' do
    subject(:search) do
      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          enable_highlighting: true,
                          dc: 1,
                          limit: 20,
                          next_offset_within_limit: true,
                          offset: 0,
                          query: 'healthy snack',
                          query_or: 'chili cheese fries',
                          query_not: 'kittens'
    end

    before do
      search.run
    end


    it 'returns a formatted query' do
      expect(search.as_json[:query]).to eq('healthy snack -kittens (chili OR cheese OR fries)')
    end
  end
end
