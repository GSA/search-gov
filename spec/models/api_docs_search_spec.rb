require 'spec_helper'

describe ApiDocsSearch do
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

  describe '#new' do
    before do
      affiliate.site_domains.create!(domain: 'whitehouse.gov')
      affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
    end

    it 'initializes AzureWebEngine' do
      AzureWebEngine.should_receive(:new).
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

  describe '#run' do
    context 'when offset is 0' do
      it 'initializes GovboxSet' do
        highlighting_options = {
          highlighting: true,
          pre_tags: ["\ue000"],
          post_tags: ["\ue001"]
        }

        GovboxSet.should_receive(:new).with(
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
        GovboxSet.should_not_receive(:new)

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
        result = search.results.first
        expect(result.title).to match(/\ue000.+\ue001/)
        expect(result.description).to match(/\ue000.+\ue001/)
        expect(result.url).to match(URI.regexp)
      end

      its(:next_offset) { should eq(20) }
      its(:modules) { should include('AWEB') }
    end

    context 'when enable_highlighting is disabled' do
      subject(:search) do
        described_class.new search_params.merge(enable_highlighting: false)
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(20)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to_not match(/\ue000.+\ue001/)
        expect(result.description).to_not match(/\ue000.+\ue001/)
      end

      its(:next_offset) { should eq(20) }
      its(:modules) { should include('AWEB') }
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

      its(:next_offset) { should be_nil }
    end

    context 'when the site locale is es' do
      let(:affiliate) { affiliates(:spanish_affiliate) }
      let(:search) do
        described_class.new search_params.merge(query: 'casa blanca', affiliate: affiliate)
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

      its(:results) { should be_empty }
      its(:modules) { should_not include('AWEB') }
    end
  end

  describe '#as_json' do
    subject(:search) { described_class.new search_params }

    before { search.run }

    it 'returns results' do
      expect(search.as_json[:docs][:results].count).to eq(20)
    end

    it 'highlights title and description' do
      result = Hashie::Mash.new(search.as_json[:docs][:results].first)
      expect(result.title).to match(/\ue000.+\ue001/i)
      expect(result.snippet).to match(/\ue000.+\ue001/i)
      expect(result.url).to match(URI.regexp)
    end
  end
end
