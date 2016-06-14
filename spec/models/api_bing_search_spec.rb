require 'spec_helper'

describe ApiBingSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  describe '#new' do
    before do
      affiliate.site_domains.create!(domain: 'whitehouse.gov')
      affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
    end

    it 'initializes BingWebSearch engine' do
      BingWebSearch.should_receive(:new).
        with(enable_highlighting: false,
             language: 'en',
             limit: 25,
             next_offset_within_limit: true,
             offset: 10,
             password: 'my_api_key',
             query: '(gov) language:en (-site:kids.usa.gov) (site:whitehouse.gov OR site:usa.gov)')

      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          enable_highlighting: false,
                          limit: 25,
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
                            query: 'food nutrition'
      end

      before do
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to match(/\ue000.+\ue001/)
        expect(result.content).to match(/\ue000.+\ue001/)
        expect(result.unescaped_url).to eq('https://www.usa.gov/food-and-nutrition')
      end

      its(:next_offset) { should eq(10) }
      its(:modules) { should include('BWEB') }
    end

    context 'when enable_highlighting is disabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: false,
                            offset: 0,
                            query: 'food nutrition'
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'title and description should NOT be highlighted' do
        result = search.results.first
        expect(result.title).to eq("Food and Nutrition | USA.gov")
        expect(result.content).to eq("Food and Nutrition. Learn about nutrition, help to feed your family, and how to safely prepare food. Food Assistance. Find out how to get help buying nutritious food ...")
      end

      its(:next_offset) { should eq(10) }
      its(:modules) { should include('BWEB') }
    end

    context 'when response _next is not present' do
      let(:query) { 'api bing no next' }
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: query
      end

      before do
        affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
        affiliate.excluded_domains.create!(domain: 'www.usa.gov')

        bing_api_url = "#{BingSearch::API_HOST}#{BingSearch::API_ENDPOINT}"
        no_next_result = Rails.root.join("spec/fixtures/json/bing/web_search/no_next.json").read
        stub_request(:get, /#{bing_api_url}.*#{query}/).
          to_return( status: 200, body: no_next_result)

        search.run
      end

      its(:next_offset) { should be_nil }
    end

    context 'when the site locale is es' do
      let(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'educación'
      end

      before do
        I18n.stub(:locale).and_return('es')
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to eq("Recursos para la \ue000educación\ue001 | GobiernoUSA.gov")
        expect(result.content).to eq("\ue000Educación\ue001. Información del Gobierno sobre ayuda para estudiantes y personas que quieren aprender inglés. Ayuda financiera para estudiantes. Becas, productos ...")
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
      affiliate.stub!(:agency).and_return(agency)

      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          enable_highlighting: true,
                          limit: 20,
                          next_offset_within_limit: true,
                          offset: 0,
                          query: 'food nutrition'
    end

    before { search.run }

    it 'returns results' do
      expect(search.as_json[:web][:results].count).to eq(10)
    end

    it 'highlights title and description' do
      result = Hashie::Mash.new(search.as_json[:web][:results].first)
      expect(result.title).to match(/\ue000.+\ue001/)
      expect(result.snippet).to match(/\ue000.+\ue001/)
      expect(result.url).to match(URI.regexp)
    end

    it_should_behave_like 'an API search as_json'
    it_should_behave_like 'a commercial API search as_json'
  end
end
