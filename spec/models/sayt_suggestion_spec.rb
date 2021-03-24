require 'spec_helper'

describe SaytSuggestion do
  let(:affiliate) { affiliates(:power_affiliate) }
  let(:valid_attributes) do
    {
      affiliate_id: affiliate.id,
      phrase: 'some valid suggestion',
      popularity: 100
    }
  end

  before do
    @affiliate = affiliates(:power_affiliate)
    @valid_attributes = {
      affiliate_id: @affiliate.id,
      phrase: 'some valid suggestion',
      popularity: 100
    }
  end

  describe 'schema' do
    it { is_expected.to have_db_index([:updated_at, :is_protected]) }
  end

  describe 'Creating new instance' do
    it { is_expected.to belong_to :affiliate }
    it { is_expected.to validate_presence_of :affiliate }
    it { is_expected.to validate_presence_of :phrase }
    it { is_expected.to validate_length_of(:phrase).is_at_least(3).is_at_most(80) }
    ['citizenship[', 'email@address.com', '"over quoted"', 'colon: here', 'http:something', 'site:something', 'intitle:something', "passports'", '.mp3', "' pictures"].each do |phrase|
      it { is_expected.not_to allow_value(phrase).for(:phrase) }
    end
    ['basic phrase', 'my-name', '1099 form', 'Senator Frank S. Farley State Marina', "Oswald West State Park's Smuggler Cove", 'en español', 'último pronóstico', '¿Qué'].each do |phrase|
      it { is_expected.to allow_value(phrase).for(:phrase) }
    end

    it 'validates the uniqueness of the phrase scoped to the affiliate id' do
      described_class.create!(@valid_attributes)
      expect(described_class.new(@valid_attributes)).to_not be_valid
    end

    it 'creates a new instance given valid attributes' do
      described_class.create!(@valid_attributes)
    end

    it 'downcases the phrase before entering into DB' do
      described_class.create!(phrase: 'ALL CAPS', affiliate: @affiliate)
      expect(described_class.find_by_phrase('all caps').phrase).to eq('all caps')
    end

    it 'strips whitespace from phrase before inserting in DB' do
      phrase = ' leading and trailing whitespaces '
      sf = described_class.create!(phrase: phrase, affiliate: @affiliate)
      expect(sf.phrase).to eq(phrase.strip)
    end

    it 'squishes multiple whitespaces between words in the phrase before entering into DB' do
      described_class.create!(phrase: 'two  spaces', affiliate: @affiliate)
      expect(described_class.find_by_phrase('two spaces').phrase).to eq('two spaces')
    end

    it 'does not correct misspellings before entering in DB if the suggestion belongs to an affiliate' do
      described_class.create!(phrase: 'barack ubama', affiliate: affiliates(:basic_affiliate))
      expect(described_class.find_by_phrase('barack ubama')).not_to be_nil
    end

    it 'defaults popularity to 1 if not specified' do
      described_class.create!(phrase: 'popular', affiliate: @affiliate)
      expect(described_class.find_by_phrase('popular').popularity).to eq(1)
    end

    it 'defaults protected status to false' do
      suggestion = described_class.create!(phrase: 'unprotected', affiliate: @affiliate)
      expect(suggestion.is_protected).to be false
    end

    it 'does not create a new suggestion if one exists, but is marked as deleted' do
      described_class.create!(phrase: 'deleted', affiliate: @affiliate, deleted_at: Time.now)
      expect(described_class.create(phrase: 'deleted', affiliate: @affiliate).id).to be_nil
    end
  end

  describe 'saving an instance' do
    before do
      SaytFilter.create!(phrase: 'accept me', is_regex: false, filter_only_exact_phrase: false, accept: true)
    end

    it 'sets the is_whitelisted flag accordingly' do
      ss = described_class.create!(phrase: 'accept me please', affiliate: @affiliate, deleted_at: Time.now)
      expect(ss.is_whitelisted).to be true
      ss = described_class.create!(phrase: 'not me please', affiliate: @affiliate, deleted_at: Time.now)
      expect(ss.is_whitelisted).to be false
    end
  end

  describe '.expire(days_back)' do
    subject(:expire) { described_class.expire(30) }

    context 'when suggestions exist' do
      before do
        described_class.create!(
          valid_attributes.merge(phrase: 'outdated', updated_at: 31.days.ago)
        )
        described_class.create!(
          valid_attributes.merge(phrase: 'outdated but protected',
                                 is_protected: true,
                                 updated_at: 31.days.ago)
        )
        described_class.create!(valid_attributes.merge(phrase: 'new'))
      end

      it 'destroys unprotected suggestions that have not been updated in X days' do
        expire
        expect(affiliate.sayt_suggestions.pluck(:phrase)).
          to eq ['new', 'outdated but protected']
      end
    end
  end

  describe '#populate_for(day, limit = nil)' do
    it 'populates SAYT suggestions for all affiliates in affiliate table' do
      Affiliate.all.each do |aff|
        expect(described_class).to receive(:populate_for_affiliate_on).with(aff.name, aff.id, Date.current, 100)
      end
      described_class.populate_for(Date.current, 100)
    end

  end

  describe '#populate_for_affiliate_on(affiliate_name, affiliate_id, day, limit)' do
    before do
      ResqueSpec.reset!
    end

    let(:aff) { affiliates(:basic_affiliate) }

    it 'enqueues the affiliate for processing' do
      described_class.populate_for_affiliate_on(aff.name, aff.id, Date.current, 100)
      expect(SaytSuggestionDiscovery).to have_queued(aff.name, aff.id, Date.current, 100)
    end

  end

  describe '#fetch_by_affiliate_id(affiliate_id, query, num_suggestions)' do
    let(:affiliate) { affiliates(:power_affiliate) }

    it 'returns empty array if there is no matching suggestion' do
      described_class.create!(phrase: 'child', popularity: 10, affiliate_id: affiliate.id)
      expect(described_class.fetch_by_affiliate_id(affiliate.id, 'kids', 10)).to be_empty
    end

    it 'returns records for that affiliate_id' do
      described_class.create!(phrase: 'child', popularity: 10, affiliate_id: affiliate.id)
      described_class.create!(phrase: 'child care', popularity: 1, affiliate_id: affiliate.id)
      described_class.create!(phrase: 'children', popularity: 100, affiliate_id: affiliate.id)
      described_class.create!(phrase: 'child default', popularity: 100, affiliate_id: affiliates(:basic_affiliate).id)

      suggestions = described_class.fetch_by_affiliate_id(affiliate.id, 'child', 10)
      expect(suggestions.size).to eq(3)
    end

    context 'when there are more than num_suggestions results available' do
      before do
        described_class.create!(phrase: 'child', popularity: 10, affiliate_id: affiliate.id)
        described_class.create!(phrase: 'child care', popularity: 1, affiliate_id: affiliate.id)
        described_class.create!(phrase: 'children', popularity: 100, affiliate_id: affiliate.id)
      end

      it 'returns at most num_suggestions results' do
        expect(described_class.fetch_by_affiliate_id(affiliate.id, 'child', 2).count).to eq(2)
      end
    end

    context 'when there are multiple suggestions available' do
      before do
        described_class.create!(phrase: 'child', popularity: 10, affiliate_id: affiliate.id)
        described_class.create!(phrase: 'child care', popularity: 1, affiliate_id: affiliate.id)
        described_class.create!(phrase: 'children', popularity: 100, affiliate_id: affiliate.id)
      end

      it 'returns results in order of popularity' do
        suggestions = described_class.fetch_by_affiliate_id(affiliate.id, 'child', 10)
        expect(suggestions.first.phrase).to eq('children')
        expect(suggestions.last.phrase).to eq('child care')
      end
    end

    context 'when multiple suggestions have the same popularity' do
      before do
        described_class.create!(phrase: 'eliz hhh', popularity: 100, affiliate_id: affiliate.id)
        described_class.create!(phrase: 'eliz aaa', popularity: 100, affiliate_id: affiliate.id)
        described_class.create!(phrase: 'eliz ggg', popularity: 100, affiliate_id: affiliate.id)
      end

      it 'returns results in alphabetical order' do
        suggestions = described_class.fetch_by_affiliate_id(affiliate.id, 'eliz', 3)
        expect(suggestions.first.phrase).to eq('eliz aaa')
        expect(suggestions.last.phrase).to eq('eliz hhh')
      end
    end
  end

  describe '#process_sayt_suggestion_txt_upload' do
    fixtures :affiliates
    let(:content_type) { 'text/plain' }

    before do
      @affiliate = affiliates(:basic_affiliate)
      @phrases = %w{ one two three }
      tempfile = File.open('spec/fixtures/txt/sayt_suggestions.txt')
      @file = Rack::Test::UploadedFile.new(tempfile, content_type)
      @dummy_suggestion = described_class.create(phrase: 'dummy suggestions')
    end

    it 'creates SAYT suggestions using the affiliate provided, if provided' do
      @phrases.each do |phrase|
        expect(described_class).to receive(:create).with({phrase: phrase, affiliate: @affiliate, is_protected: true, popularity: SaytSuggestion::MAX_POPULARITY}).and_return @dummy_suggestion
      end
      described_class.process_sayt_suggestion_txt_upload(@file, @affiliate)
    end
  end

  describe '#to_label' do
    it 'returns the phrase' do
      expect(described_class.new(phrase: 'dummy suggestion', affiliate: @affiliate).to_label).to eq('dummy suggestion')
    end
  end

  describe '#related_search' do
    before do
      @affiliate = affiliates(:basic_affiliate)
      described_class.destroy_all
      described_class.create!(affiliate_id: @affiliate.id, phrase: 'suggest me', popularity: 30)
      ElasticSaytSuggestion.commit
    end

    it 'returns an array of highlighted strings' do
      expect(described_class.related_search('suggest', @affiliate)).to eq(['<strong>suggest</strong> me'])
    end

    context 'when affiliate has related searches disabled' do
      before do
        @affiliate.is_related_searches_enabled = false
      end

      it 'returns an empty array' do
        expect(described_class.related_search('suggest', @affiliate)).to eq([])
      end
    end

  end
end
