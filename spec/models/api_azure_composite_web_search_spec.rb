require 'spec_helper'

describe ApiAzureCompositeWebSearch do
  fixtures :affiliates

  let(:api_key) { nil }

  subject do
    described_class.new({
      affiliate: affiliates(:basic_affiliate),
      query: '(site: www.census.gov)',
      api_key: api_key,
    })
  end

  describe '#new' do
    context 'when initialized with a Bing V2 key' do
      let(:api_key) { AzureEngine::DEFAULT_AZURE_HOSTED_PASSWORD }

      it 'instantiates an AzureCompositeEngine' do
        expect(AzureCompositeEngine).to receive(:new)
        subject
      end

      it 'uses module tag AZCW' do
        expect(subject.default_module_tag).to eq('AZCW')
      end
    end

    context 'when initialized with a Bing V5 key' do
      let(:api_key) { BingV5HostedSubscriptionKey::BING_V5_SUBSCRIPTION_KEY }

      it 'instantiates a BingV5WebEngine' do
        expect(BingV5WebEngine).to receive(:new)
        subject
      end

      it 'uses module tag BV5W' do
        expect(subject.default_module_tag).to eq('BV5W')
      end
    end
  end

  describe '#to_json' do
    let(:spelling_suggestion) { nil }
    let(:engine_response) do
      Hashie::Mash.new({
        total: 42,
        next_offset: 5,
        spelling_suggestion: spelling_suggestion,
        results: [
          {
            id: '29980fef-ba48-40cc-af52-57a3a253b819',
            display_url: 'www.census.gov/programs-surveys/acs',
            title: 'American Community Survey',
            url: 'http://www.census.gov/programs-surveys/acs/',
            description: 'The American Community Survey (ACS) is a mandatory, ongoing statistical survey that samples a small percentage of the population every year.',
          }
        ],
      })
    end

    before do
      subject.handle_response(engine_response)
    end

    it 'includes the total and next_offset' do
      json = Hashie::Mash.new(subject.as_json)

      expect(json.web.total).to eq(42)
      expect(json.web.next_offset).to eq(5)
    end

    it 'includes title, url, snippet for each individual result' do
      result = Hashie::Mash.new(subject.as_json).web.results.first

      expect(result.title).to eq('American Community Survey')
      expect(result.url).to eq('http://www.census.gov/programs-surveys/acs/')
      expect(result.display_url).to eq('www.census.gov/programs-surveys/acs')
      expect(result.snippet).to eq('The American Community Survey (ACS) is a mandatory, ongoing statistical survey that samples a small percentage of the population every year.')
    end

    context 'when no spelling suggestion is present' do
      it 'does not include a spelling suggestion' do
        json = Hashie::Mash.new(subject.as_json)

        expect(json.web.spelling_suggestion).to eq(nil)
      end
    end

    context 'when a spelling suggestion is present' do
      let(:spelling_suggestion) { 'correction' }

      it 'includes the spelling suggestion' do
        json = Hashie::Mash.new(subject.as_json)

        expect(json.web.spelling_suggestion).to eq('correction')
      end
    end
  end
end
