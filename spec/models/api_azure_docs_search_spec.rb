require 'spec_helper'

describe ApiAzureDocsSearch do
  #disabling until tests are removed:
  #https://www.pivotaltracker.com/story/show/134719601

  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:api_key) { AzureEngine::DEFAULT_AZURE_HOSTED_PASSWORD }
  let(:search_params) do
    { affiliate: affiliate,
      api_key: api_key,
      enable_highlighting: true,
      limit: 20,
      dc: 1,
      next_offset_within_limit: true,
      offset: 0,
      query: 'nutrition' }
  end

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  skip '#new' do
    before do
      affiliate.site_domains.create!(domain: 'whitehouse.gov')
      affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
    end

    it 'initializes AzureWebEngine' do
      expect(AzureWebEngine).to receive(:new). \
        with(enable_highlighting: true,
             language: 'en',
             limit: 20,
             next_offset_within_limit: true,
             offset: 0,
             password: api_key,
             query: 'nutrition (site:whitehouse.gov OR site:usa.gov) (-site:kids.usa.gov)')

      described_class.new search_params
    end
  end

  skip '#run' do
    context 'when offset is 0' do
      it 'initializes GovboxSet' do
        highlighting_options = {
          highlighting: true,
          pre_tags: ["\ue000"],
          post_tags: ["\ue001"]
        }

        expect(GovboxSet).to receive(:new).with(
          'nutrition',
          affiliate,
          nil,
          highlighting_options)

        described_class.new(search_params).run
      end
    end

    context 'when offset is not 0' do
      before { search_params.merge!(offset: 888) }

      it 'does not initialize GovboxSet' do
        expect(GovboxSet).not_to receive(:new)

        described_class.new(search_params).run
      end
    end

    context 'when enable_highlighting is enabled' do
      subject(:search) { described_class.new search_params }

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(20)
      end

      it 'highlights title and description' do
        expect(search.results.map(&:title).compact).to include(match(/\ue000.+\ue001/))
        expect(search.results.map(&:description).compact).to include(match(/\ue000.+\ue001/))
      end

      it 'includes urls' do
        expect(search.results.map(&:url).compact).to include(match(URI.regexp))
      end

      its(:next_offset) { is_expected.to eq(20) }
      its(:modules) { is_expected.to include('AWEB') }
    end

    context 'when enable_highlighting is disabled' do
      subject(:search) do
        described_class.new search_params.merge(enable_highlighting: false)
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(20)
      end

      it 'does not highlight title or description' do
        expect(search.results.map(&:title).compact).to_not include(match(/\ue000.+\ue001/))
        expect(search.results.map(&:description).compact).to_not include(match(/\ue000.+\ue001/))
      end

      its(:next_offset) { is_expected.to eq(20) }
      its(:modules) { is_expected.to include('AWEB') }
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
                            query: 'healthy snack'
      end

      before do
        affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
        affiliate.excluded_domains.create!(domain: 'www.usa.gov')
        search.run
      end

      its(:next_offset) { is_expected.to be_nil }
    end

    context 'when the site locale is es' do
      let(:affiliate) { affiliates(:spanish_affiliate) }
      let(:search) do
        described_class.new search_params.merge(query: 'gobierno', affiliate: affiliate)

      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(20)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to match(/\ue000.+\ue001/)
        expect(result.description).to match(/\ue000.+\ue001/)
      end
    end

    context 'when Azure response contains empty results' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'mango smoothie'
      end

      before { search.run }

      its(:results) { is_expected.to be_empty }
      its(:modules) { is_expected.not_to include('AWEB') }
    end
  end

  skip '#as_json' do
    subject(:search) { described_class.new search_params }

    before { search.run }

    it 'returns results' do
      expect(search.as_json[:docs][:results].count).to eq(20)
    end

    it 'returns a formatted query' do
      expect(search.as_json[:query]).to eq('nutrition')
    end

    it 'highlights title and snippet' do
      results = search.as_json[:docs][:results].map { |r| Hashie::Mash.new(r) }
      expect(results.map(&:title).compact).to include(match(/\ue000.+\ue001/i))
      expect(results.map(&:snippet).compact).to include(match(/\ue000.+\ue001/i))
    end

    it 'includes urls' do
      results = search.as_json[:docs][:results].map { |r| Hashie::Mash.new(r) }
      expect(results.map(&:url).compact).to include(match(URI.regexp))
    end
  end

  skip '#as_json with advanced query operators' do
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
