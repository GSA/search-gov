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

        GovboxSet.should_receive(:new).with(
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
        GovboxSet.should_not_receive(:new)

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
                            query: 'healthy snack'
      end

      before do
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and description' do
        result = search.results.second
        expect(result.title).to eq("\ue000Healthy Snack\ue001 #3: Cucumber Yogurt Dip | Video | Kids.gov ...")
        expect(result.content).to eq("Video Description: Learn how to make a cool and \ue000healthy\ue001 dip to eat with your favorite veggies. Ingredients: Dip: 2 cups yogurt (plain, low-fat) 2 cucumber (large ...")
        expect(result.unescaped_url).to eq('https://kids.usa.gov/watch-videos/exercise-and-eating-healthy/cucumber-dip/index.shtml')
      end

      its(:next_offset) { should eq(10) }
      its(:modules) { should include('BWEB') }
    end

    context 'when enable_highlighting is disabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: false,
                            limit: 20,
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
        expect(result.title).to eq("Peanut Butter and Apple Wrap | Video | Kids.gov | USAGov")
        expect(result.content).to eq("Video Description: Ingredients and steps to prepare the \"Peanut Butter and Apple Wrap\" snack. Ingredients: Whole-wheat tortilla Peanut butter, sunflower seed butter ...")
      end

      its(:next_offset) { should eq(10) }
      its(:modules) { should include('BWEB') }
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
      let(:search) do
        described_class.new affiliate: affiliate,
                            api_key: 'my_api_key',
                            enable_highlighting: true,
                            limit: 20,
                            dc: 1,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'educación'
      end

      before do
        # Language.stub(:find_by_code).with('es').and_return(mock_model(Language, is_azure_supported: true, inferred_country_code: 'US'))
        # affiliate.locale = 'es'
        I18n.stub(:locale).and_return('es')
        search.run
      end

      it 'returns results' do
        expect(search.results.count).to eq(10)
      end

      it 'highlights title and description' do
        result = search.results[0]
        expect(result.title).to eq("Recursos para la \ue000educación\ue001 | USAGov")
        expect(result.content).to eq("Becas, productos financieros y programas del Gobierno para la \ue000educación\ue001 superior. Recursos educativos. Información sobre programas o materiales para estudiar.")
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
      its(:modules) { should_not include('BWEB') }
    end
  end

  describe '#as_json' do
    subject(:search) do
      described_class.new affiliate: affiliate,
                          api_key: 'my_api_key',
                          enable_highlighting: true,
                          dc: 1,
                          limit: 20,
                          next_offset_within_limit: true,
                          offset: 0,
                          query: 'healthy snack'
    end

    before { search.run }

    it 'returns results' do
      expect(search.as_json[:docs][:results].count).to eq(10)
    end

    it 'highlights title and description' do
      result = Hashie::Mash.new(search.as_json[:docs][:results].second)
      expect(result.title).to eq("\ue000Healthy Snack\ue001 #5: Frozen Fruit Cups | Videos | Kids.gov ...")
      expect(result.snippet).to eq("\ue000Healthy Snack\ue001 #5: Frozen Fruit Cups ... And for more about eating healthy, visit Kids.gov. Original Recipe. Note: This recipe has not been standardized by USDA.")
      expect(result.url).to eq('https://kids.usa.gov/watch-videos/exercise-and-eating-healthy/fruit-cups/index.shtml')
    end
  end
end
