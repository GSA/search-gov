require 'spec_helper'

describe ApiBingDocsSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  describe '#new' do
    before do
      affiliate.site_domains.create!(domain: 'whitehouse.gov')
      affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
    end

    it 'initializes BingWebSearch' do
      expect(BingV6WebSearch).to receive(:new).
        with(enable_highlighting: false,
             language: 'en',
             limit: 10,
             next_offset_within_limit: true,
             offset: 10,
             password: 'my_api_key',
             query: 'gov (site:whitehouse.gov OR site:usa.gov) (-site:kids.usa.gov)')

      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          enable_highlighting: false,
                          limit: 10,
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
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 888,
                            query: 'healthy snack').run
      end
    end

    context 'when enable_highlighting is enabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            limit: 10,
                            query: 'healthy snack'
      end

      before do
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and content' do
        expect(search.results.map(&:title)).to include(match(/\ue000.+\ue001/))
        expect(search.results.map(&:content)).to include(match(/\ue000.+\ue001/))
        expect(search.results.first.unescaped_url).to match(URI.regexp)
      end

      its(:next_offset) { is_expected.to eq(10) }
      its(:modules) { is_expected.to include('BWEB') }
    end

    context 'when enable_highlighting is disabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: false,
                            limit: 10,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'healthy snack'
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'does not highlight title and description' do
        result = search.results.first
        expect(result.title).to_not match(/\ue000.+\ue001/)
        expect(result.content).to_not match(/\ue000.+\ue001/)
      end

      its(:next_offset) { is_expected.to eq(10) }
      its(:modules) { is_expected.to include('BWEB') }
    end

    context 'when response _next is not present' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 10,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'healthy snack'
      end

      before do
        affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
        affiliate.excluded_domains.create!(domain: 'www.usa.gov')
        search.run
      end

      its(:next_offset) { should be_nil }
    end

    context 'when the site locale is es' do
      let(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 10,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'educación'
      end

      before do
        # Language.stub(:find_by_code).with('es').and_return(mock_model(Language, is_azure_supported: true, inferred_country_code: 'US'))
        # affiliate.locale = 'es'
        allow(I18n).to receive(:locale).and_return('es')
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and content' do
        expect(search.results.map(&:title).compact).to include(match(/\ue000.+\ue001/))
        expect(search.results.map(&:content).compact).to include(match(/\ue000.+\ue001/))
      end
    end

    context 'when Azure response contains empty results' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 10,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'mango smoothie'
      end

      before { search.run }

      its(:results) { should be_empty }
      its(:modules) { should_not include('BWEB') }
    end
  end

  describe '#as_json' do
    subject(:search) do
      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          enable_highlighting: true,
                          dc: 1,
                          limit: 10,
                          next_offset_within_limit: true,
                          offset: 0,
                          query: 'healthy snack'
    end

    before do
      search.run
    end

    it 'returns results' do
      expect(search.as_json[:docs][:results].count).to eq(10)
    end

    it 'returns a formatted query' do
      expect(search.as_json[:query]).to eq('healthy snack')
    end

    it 'highlights title and description' do
      result = Hashie::Mash.new(search.as_json[:docs][:results].second)
      expect(result.title).to match(/\ue000.+\ue001/)
      expect(result.snippet).to match(/\ue000.+\ue001/)
      expect(result.url).to match(URI.regexp)
    end
  end

  describe '#as_json with advanced query operators' do
    subject(:search) do
      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          enable_highlighting: true,
                          dc: 1,
                          limit: 10,
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
