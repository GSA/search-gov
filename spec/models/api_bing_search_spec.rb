require 'spec_helper'

describe ApiBingSearch, vcr: { re_record_interval: 4.months } do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:search_params) do
    { affiliate: affiliate,
      api_key: 'my_api_key',
      enable_highlighting: true,
      limit: 20,
      next_offset_within_limit: true,
      offset: 0,
      query: 'food nutrition' }
  end

  let(:search) { ApiBingSearch.new search_params }

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  it_should_behave_like 'a commercial API search'

  describe '#new' do
    before do
      affiliate.site_domains.create!(domain: 'whitehouse.gov')
      affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
    end

    it 'initializes BingV6WebSearch engine' do
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
                          next_offset_within_limit: true,
                          offset: 10,
                          query: 'gov'
    end
  end

  describe '#run' do
    context 'when enable_highlighting is enabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: true,
                            offset: 0,
                            limit: 10,
                            query: 'food nutrition'
      end

      before do
        search.run
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

      its(:next_offset) { is_expected.to eq(10) }
      its(:modules) { is_expected.to include('BWEB') }
    end

    context 'when enable_highlighting is disabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: false,
                            offset: 0,
                            limit: 10,
                            query: 'food nutrition'
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'title and description should NOT be highlighted' do
        result = search.results.first
        expect(result.title).to_not match(/\ue000.+\ue001/)
        expect(result.content).to_not match(/\ue000.+\ue001/)
      end

      its(:next_offset) { is_expected.to eq(10) }
      its(:modules) { is_expected.to include('BWEB') }
    end

    context 'when the site locale is es' do
      let(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 10,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'educación'
      end

      before do
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

    context 'when the response contains empty results' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
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
    subject(:search) do
      agency = Agency.create!({:name => 'Some New Agency', :abbreviation => 'SNA' })
      AgencyOrganizationCode.create!(organization_code: "XX00", agency: agency)
      allow(affiliate).to receive(:agency).and_return(agency)

      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          enable_highlighting: true,
                          limit: 10,
                          next_offset_within_limit: true,
                          offset: 0,
                          query: 'food nutrition'
    end

    before { search.run }

    it 'returns results' do
      expect(search.as_json[:web][:results].count).to eq(10)
    end

    it 'highlights title and description' do
      results = search.as_json[:web][:results].map{|result| Hashie::Mash.new(result) }
      result = results.first

      expect(results.map(&:title).compact).to include(match(/\ue000.+\ue001/))
      expect(results.map(&:snippet).compact).to include(match(/\ue000.+\ue001/))
      expect(result.url).to match(URI.regexp)
    end

    it_should_behave_like 'an API search as_json'
    it_should_behave_like 'a commercial API search as_json'
  end
end
