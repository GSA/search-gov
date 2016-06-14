require 'spec_helper'

describe ApiGssSearch do
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
      subject(:search) { described_class.new search_params }

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to match(/\ue000.+\ue001/)
        expect(result.description).to match(/\ue000.+\ue001/)
        expect(result.url).to match(URI.regexp)
      end

      its(:next_offset) { should eq(10) }
      its(:modules) { should include('GWEB') }
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
        expect(result.description).to_not match(/\ue000.+\ue001/)
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
                            query: 'gss no next'
      end

      before do
        google_api_url = "#{GoogleSearch::API_HOST}#{GoogleSearch::API_ENDPOINT}"
        google_no_next = Rails.root.join('spec/fixtures/json/google/web_search/no_next.json').read
        stub_request(:get, /#{google_api_url}.*gss no next/).
          to_return( status: 200, body:  google_no_next )

        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(3)
      end

      its(:next_offset) { should be_nil }
    end

    context 'when the site locale is es' do
      let(:affiliate) { affiliates(:spanish_affiliate) }
      let(:search)  { described_class.new search_params.merge(query: 'casa blanca') }

      before do
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to match(/\ue000.+\ue001/)
        expect(result.description).to match(/\ue000.+\ue001/)
        expect(result.url).to match(URI.regexp)
      end
    end

    context 'when correctedQuery is present' do
      subject(:search) do
        described_class.new search_params.merge(query: 'electro coagulation')
      end

      it_should_behave_like 'a search with spelling suggestion'
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
      agency = Agency.create!({:name => 'Some New Agency', :abbreviation => 'SNA' })
      AgencyOrganizationCode.create!(organization_code: "XX00", agency: agency)
      affiliate.stub!(:agency).and_return(agency)

      described_class.new search_params.merge(query: 'electro coagulation')
    end

    before { search.run }

    it 'returns results' do
      expect(search.as_json[:web][:results].count).to be > 1
    end

    it 'highlights title and description' do
      result = Hashie::Mash.new(search.as_json[:web][:results].first)
      expect(result.title).to match(/\ue000.+\ue001/)
      expect(result.snippet).to match(/\ue000.+\ue001/)
      expect(result.url).to match(URI.regexp)
    end

    it 'sets spelling suggestion' do
      expect(search.as_json[:web][:spelling_correction]).to eq('electrocoagulation')
    end

    it_should_behave_like 'an API search as_json'
    it_should_behave_like 'a commercial API search as_json'
  end
end
