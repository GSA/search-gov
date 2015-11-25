require 'spec_helper'

describe ApiAzureSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  describe '#new' do
    before do
      affiliate.site_domains.create!(domain: 'whitehouse.gov')
      affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
    end

    it 'initializes AzureWebEngine' do
      AzureWebEngine.should_receive(:new).
        with(enable_highlighting: false,
             language: 'en',
             limit: 25,
             next_offset_within_limit: true,
             offset: 10,
             password: 'my_api_key',
             query: 'gov (site:whitehouse.gov OR site:usa.gov) (-site:kids.usa.gov)')

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
    context 'when offset is 0' do
      it 'initializes GovboxSet' do
        highlighting_options = {
          highlighting: true,
          pre_tags: ["\ue000"],
          post_tags: ["\ue001"]
        }

        GovboxSet.should_receive(:new).with(
          'healthy snack',
          affiliate,
          nil,
          highlighting_options)

        described_class.new(affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'healthy snack').run
      end
    end

    context 'when offset is not 0' do
      it 'does not initialize GovboxSet' do
        GovboxSet.should_not_receive(:new)

        described_class.new(affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
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
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'healthy snack'
      end

      before do
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(20)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to eq("Exercise and Eating \ue000Healthy\ue001 for Kids | Grades K - 5 | Kids.gov")
        expect(result.description).to eq("Exercise and Eating \ue000Healthy\ue001 for Kids | Grades K - 5 ... What gear do you need for a sport? See a list here")
        expect(result.url).to eq('http://kids.usa.gov/exercise-and-eating-healthy/index.shtml')
      end

      its(:next_offset) { should eq(20) }
      its(:modules) { should include('AWEB') }
    end

    context 'when enable_highlighting is disabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: false,
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'healthy snack'
      end

      before { search.run }

      it 'returns results' do
        expect(search.results.count).to eq(20)
      end

      it 'highlights title and description' do
        result = search.results.first
        expect(result.title).to eq("Exercise and Eating Healthy for Kids | Grades K - 5 | Kids.gov")
        expect(result.description).to eq("Exercise and Eating Healthy for Kids | Grades K - 5 ... What gear do you need for a sport? See a list here")
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
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'educación'
      end

      before do
        Language.stub(:find_by_code).with('es').and_return(mock_model(Language, is_azure_supported: true, inferred_country_code: 'US'))
        affiliate.locale = 'es'
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(20)
      end

      it 'highlights title and description' do
        result = search.results[1]
        expect(result.title).to eq("\ue000Educación\ue001 para recién llegados | GobiernoUSA.gov")
        expect(result.description).to eq("\ue000Educación\ue001 para recién llegados en GobiernoUSA.gov ... Identifique un programa para después del horario escolar para su hijo; Información sobre becas y servicios ...")
      end
    end

    context 'when Azure response contains empty results' do
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
                          query: 'healthy snack'
    end

    before { search.run }

    it 'returns results' do
      expect(search.as_json[:web][:results].count).to eq(20)
    end

    it 'highlights title and description' do
      result = Hashie::Mash.new(search.as_json[:web][:results].first)
      expect(result.title).to eq("Exercise and Eating \ue000Healthy\ue001 for Kids | Grades K - 5 | Kids.gov")
      expect(result.snippet).to eq("Exercise and Eating \ue000Healthy\ue001 for Kids | Grades K - 5 ... What gear do you need for a sport? See a list here")
      expect(result.url).to eq('http://kids.usa.gov/exercise-and-eating-healthy/index.shtml')
    end

    it_should_behave_like 'an API search as_json'
    it_should_behave_like 'a commercial API search as_json'
  end
end
