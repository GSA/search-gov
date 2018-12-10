require 'spec_helper'

describe ApiAzureCompositeImageSearch do
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

      it 'uses module tag AZCI' do
        expect(subject.default_module_tag).to eq('AZCI')
      end
    end

    context 'when initialized with a Bing V5 key' do
      let(:api_key) { BingV5HostedSubscriptionKey::BING_V5_SUBSCRIPTION_KEY }

      it 'instantiates a BingV5ImageEngine' do
        expect(BingV5ImageEngine).to receive(:new)
        subject
      end

      it 'uses module tag BV5I' do
        expect(subject.default_module_tag).to eq('BV5I')
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
          title: '... why am I also getting something called the American Community Survey',
          media_url: 'http://www.census.gov/2010census/img/survey2.jpg',
          source_url: 'http://www.census.gov/2010census/about/answers.php',
          display_url: 'www.census.gov/2010census/about/answers.php',
          width: '244',
          height: '250',
          file_size: '67189',
          content_type: 'image/jpeg',
          thumbnail: {
            _metadata: {
              type: 'Bing.Thumbnail'
            },
            media_url: 'http://ts2.mm.bing.net/th?id=OIP.M9a1c4bcae075e979098413a3b65e11beo0&pid=15.1',
            content_type: 'image/jpg',
            width: '244',
            height: '250',
            file_size: '10203'
          }
        ],
      })
    end

    before do
      subject.handle_response(engine_response)
    end

    it 'includes the total and next_offset' do
      json = Hashie::Mash.new(subject.as_json)

      expect(json.images.total).to eq(42)
      expect(json.images.next_offset).to eq(5)
    end

    it 'includes details for each individual result' do
      result = Hashie::Mash.new(subject.as_json).images.results.first

      expect(result.title).to eq('... why am I also getting something called the American Community Survey')
      expect(result.url).to eq('http://www.census.gov/2010census/about/answers.php')
      expect(result.media_url).to eq('http://www.census.gov/2010census/img/survey2.jpg')
      expect(result.display_url).to eq('www.census.gov/2010census/about/answers.php')
      expect(result.content_type).to eq('image/jpeg')
      expect(result.file_size).to eq('67189')
      expect(result.width).to eq('244')
      expect(result.height).to eq('250')

      thumbnail = result.thumbnail
      expect(thumbnail.url).to eq('http://ts2.mm.bing.net/th?id=OIP.M9a1c4bcae075e979098413a3b65e11beo0&pid=15.1')
      expect(thumbnail.content_type).to eq('image/jpg')
      expect(thumbnail.file_size).to eq('10203')
      expect(thumbnail.width).to eq('244')
      expect(thumbnail.height).to eq('250')
    end

    context 'when no spelling suggestion is present' do
      it 'does not include a spelling suggestion' do
        json = Hashie::Mash.new(subject.as_json)

        expect(json.images.spelling_suggestion).to eq(nil)
      end
    end

    context 'when a spelling suggestion is present' do
      let(:spelling_suggestion) { 'correction' }

      it 'includes the spelling suggestion' do
        json = Hashie::Mash.new(subject.as_json)

        expect(json.images.spelling_suggestion).to eq('correction')
      end
    end
  end
end
