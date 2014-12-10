require 'spec_helper'

describe ApiGssSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  describe '#new' do
    before do
      affiliate.site_domains.create!(domain: 'whitehouse.gov')
      affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
    end

    it 'initializes ApiGssWebEngine' do
      ApiGssWebEngine.should_receive(:new).
        with(google_cx: 'my_cx',
             google_key: 'my_api_key',
             enable_highlighting: false,
             language: 'lang_en',
             per_page: 8,
             next_offset_within_limit: true,
             offset: 10,
             query: 'gov -site:kids.usa.gov site:whitehouse.gov OR site:usa.gov')

      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          cx: 'my_cx',
                          enable_highlighting: false,
                          limit: 8,
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

        GovboxSet.should_receive(:new).with(
          'ira',
          affiliate,
          nil,
          highlighting_options)

        described_class.new(affiliate: affiliate,
                            api_key: 'my_api_key',
                            cx: 'my_cx',
                            enable_highlighting: true,
                            limit: 10,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'ira').run
      end
    end

    context 'when offset is not 0' do
      it 'does not initialize GovboxSet' do
        GovboxSet.should_not_receive(:new)

        described_class.new(affiliate: affiliate,
                            api_key: 'my_api_key',
                            cx: 'my_cx',
                            enable_highlighting: true,
                            limit: 5,
                            next_offset_within_limit: true,
                            offset: 888,
                            query: 'ira').run
      end
    end

    context 'when highlighting is enabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            cx: 'my_cx',
                            enable_highlighting: true,
                            limit: 10,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'ira'
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to eq("Publication 590 (2011), Individual Retirement Arrangements (\ue000IRAs\ue001)")
        expect(result.description).to eq("Examples — Worksheet for Reduced \ue000IRA\ue001 Deduction for 2011; What if You Inherit an \ue000IRA\ue001? Treating it as your own. Can You Move Retirement Plan Assets?")
        expect(result.url).to eq('http://www.irs.gov/publications/p590/index.html')
      end

      its(:next_offset) { should eq(10) }
      its(:modules) { should include('GWEB') }
    end

    context 'when highlighting is disabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            cx: 'my_cx',
                            enable_highlighting: false,
                            limit: 10,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'ira'
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'return non highlighted title and description' do
        result = search.results.first
        expect(result.title).to eq('Publication 590 (2011), Individual Retirement Arrangements (IRAs)')
        expect(result.description).to eq('Examples — Worksheet for Reduced IRA Deduction for 2011; What if You Inherit an IRA? Treating it as your own. Can You Move Retirement Plan Assets?')
      end

      its(:next_offset) { should eq(10) }
      its(:modules) { should include('GWEB') }
    end

    context 'when response queries.next_page is not present' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            cx: 'my_cx',
                            enable_highlighting: true,
                            limit: 10,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'healthy snack'
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(3)
      end

      its(:next_offset) { should be_nil }
    end

    context 'when the site locale is es' do
      let(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            cx: 'my_cx',
                            enable_highlighting: true,
                            limit: 10,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'casa blanca'
      end

      before do
        affiliate.locale = :es
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to eq("Publication 590 (2011), Individual Retirement Arrangements (\ue000IRAs\ue001)")
        expect(result.description).to eq("Examples — Worksheet for Reduced \ue000IRA\ue001 Deduction for 2011; What if You Inherit an \ue000IRA\ue001? Treating it as your own. Can You Move Retirement Plan Assets?")
        expect(result.url).to eq('http://www.irs.gov/publications/p590/index.html')
      end
    end

    context 'when Gss response contains empty results' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            cx: 'my_cx',
                            enable_highlighting: true,
                            limit: 10,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'mango smoothie'
      end

      before { search.run }

      its(:results) { should be_empty }
      its(:modules) { should_not include('GWEB') }
    end
  end

  describe '#as_json' do
    subject(:search) do
      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          cx: 'my_cx',
                          enable_highlighting: true,
                          limit: 10,
                          next_offset_within_limit: true,
                          offset: 0,
                          query: 'ira'
    end

    before do
      search.run
    end

    it 'returns results' do
      expect(search.as_json[:web][:results].count).to eq(10)
    end

    it 'highlights title and description' do
      result = Hashie::Mash.new(search.as_json[:web][:results].first)
      expect(result.title).to eq("Publication 590 (2011), Individual Retirement Arrangements (\ue000IRAs\ue001)")
      expect(result.snippet).to eq("Examples — Worksheet for Reduced \ue000IRA\ue001 Deduction for 2011; What if You Inherit an \ue000IRA\ue001? Treating it as your own. Can You Move Retirement Plan Assets?")
      expect(result.url).to eq('http://www.irs.gov/publications/p590/index.html')
    end
  end
end
