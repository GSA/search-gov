# coding: utf-8
require 'spec_helper'

describe SaytSuggestion do
  fixtures :sayt_suggestions, :misspellings, :affiliates
  before do
    @affiliate = affiliates(:power_affiliate)
    @valid_attributes = {
      :affiliate_id => @affiliate.id,
      :phrase => 'some valid suggestion',
      :popularity => 100
    }
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
      SaytSuggestion.create!(@valid_attributes)
      expect(SaytSuggestion.new(@valid_attributes)).to_not be_valid
    end

    it 'should create a new instance given valid attributes' do
      SaytSuggestion.create!(@valid_attributes)
    end

    it 'should downcase the phrase before entering into DB' do
      SaytSuggestion.create!(:phrase => 'ALL CAPS', :affiliate => @affiliate)
      expect(SaytSuggestion.find_by_phrase('all caps').phrase).to eq('all caps')
    end

    it 'should strip whitespace from phrase before inserting in DB' do
      phrase = ' leading and trailing whitespaces '
      sf = SaytSuggestion.create!(:phrase => phrase, :affiliate => @affiliate)
      expect(sf.phrase).to eq(phrase.strip)
    end

    it 'should squish multiple whitespaces between words in the phrase before entering into DB' do
      SaytSuggestion.create!(:phrase => 'two  spaces', :affiliate => @affiliate)
      expect(SaytSuggestion.find_by_phrase('two spaces').phrase).to eq('two spaces')
    end

    it 'should not correct misspellings before entering in DB if the suggestion belongs to an affiliate' do
      SaytSuggestion.create!(:phrase => 'barack ubama', :affiliate => affiliates(:basic_affiliate))
      expect(SaytSuggestion.find_by_phrase('barack ubama')).not_to be_nil
    end

    it 'should default popularity to 1 if not specified' do
      SaytSuggestion.create!(:phrase => 'popular', :affiliate => @affiliate)
      expect(SaytSuggestion.find_by_phrase('popular').popularity).to eq(1)
    end

    it 'should default protected status to false' do
      suggestion = SaytSuggestion.create!(:phrase => 'unprotected', :affiliate => @affiliate)
      expect(suggestion.is_protected).to be false
    end

    it 'should not create a new suggestion if one exists, but is marked as deleted' do
      SaytSuggestion.create!(:phrase => 'deleted', :affiliate => @affiliate, :deleted_at => Time.now)
      expect(SaytSuggestion.create(:phrase => 'deleted', :affiliate => @affiliate).id).to be_nil
    end
  end

  describe 'saving an instance' do
    before do
      SaytFilter.create!(:phrase => 'accept me', :is_regex => false, :filter_only_exact_phrase => false, :accept => true)
    end

    it 'should set the is_whitelisted flag accordingly' do
      ss = SaytSuggestion.create!(:phrase => 'accept me please', :affiliate => @affiliate, :deleted_at => Time.now)
      expect(ss.is_whitelisted).to be true
      ss = SaytSuggestion.create!(:phrase => 'not me please', :affiliate => @affiliate, :deleted_at => Time.now)
      expect(ss.is_whitelisted).to be false
    end
  end

  describe '#expire(days_back)' do
    it 'should destroy suggestions that have not been updated in X days, and that are unprotected' do
      expect(SaytSuggestion).to receive(:destroy_all).with(['updated_at < ? AND is_protected = ?', 30.days.ago.beginning_of_day.to_s(:db), false])
      SaytSuggestion.expire(30)
    end
  end

  describe '#populate_for(day, limit = nil)' do
    it 'should populate SAYT suggestions for all affiliates in affiliate table' do
      Affiliate.all.each do |aff|
        expect(SaytSuggestion).to receive(:populate_for_affiliate_on).with(aff.name, aff.id, Date.current, 100)
      end
      SaytSuggestion.populate_for(Date.current, 100)
    end

  end

  describe '#populate_for_affiliate_on(affiliate_name, affiliate_id, day, limit)' do
    before do
      ResqueSpec.reset!
    end

    let(:aff) { affiliates(:basic_affiliate) }

    it 'should enqueue the affiliate for processing' do
      SaytSuggestion.populate_for_affiliate_on(aff.name, aff.id, Date.current, 100)
      expect(SaytSuggestionDiscovery).to have_queued(aff.name, aff.id, Date.current, 100)
    end

  end

  describe '#fetch_by_affiliate_id(affiliate_id, query, num_suggestions)' do
    let(:affiliate) { affiliates(:power_affiliate) }

    it 'should return empty array if there is no matching suggestion' do
      SaytSuggestion.create!(:phrase => 'child', :popularity => 10, :affiliate_id => affiliate.id)
      expect(SaytSuggestion.fetch_by_affiliate_id(affiliate.id, 'kids', 10)).to be_empty
    end

    it 'should return records for that affiliate_id' do
      SaytSuggestion.create!(:phrase => 'child', :popularity => 10, :affiliate_id => affiliate.id)
      SaytSuggestion.create!(:phrase => 'child care', :popularity => 1, :affiliate_id => affiliate.id)
      SaytSuggestion.create!(:phrase => 'children', :popularity => 100, :affiliate_id => affiliate.id)
      SaytSuggestion.create!(:phrase => 'child default', :popularity => 100, :affiliate_id => affiliates(:basic_affiliate).id)

      suggestions = SaytSuggestion.fetch_by_affiliate_id(affiliate.id, 'child', 10)
      expect(suggestions.size).to eq(3)
    end

    context 'when there are more than num_suggestions results available' do
      before do
        SaytSuggestion.create!(:phrase => 'child', :popularity => 10, :affiliate_id => affiliate.id)
        SaytSuggestion.create!(:phrase => 'child care', :popularity => 1, :affiliate_id => affiliate.id)
        SaytSuggestion.create!(:phrase => 'children', :popularity => 100, :affiliate_id => affiliate.id)
      end

      it 'should return at most num_suggestions results' do
        expect(SaytSuggestion.fetch_by_affiliate_id(affiliate.id, 'child', 2).count).to eq(2)
      end
    end

    context 'when there are multiple suggestions available' do
      before do
        SaytSuggestion.create!(:phrase => 'child', :popularity => 10, :affiliate_id => affiliate.id)
        SaytSuggestion.create!(:phrase => 'child care', :popularity => 1, :affiliate_id => affiliate.id)
        SaytSuggestion.create!(:phrase => 'children', :popularity => 100, :affiliate_id => affiliate.id)
      end

      it 'should return results in order of popularity' do
        suggestions = SaytSuggestion.fetch_by_affiliate_id(affiliate.id, 'child', 10)
        expect(suggestions.first.phrase).to eq('children')
        expect(suggestions.last.phrase).to eq('child care')
      end
    end

    context 'when multiple suggestions have the same popularity' do
      before do
        SaytSuggestion.create!(:phrase => 'eliz hhh', :popularity => 100, :affiliate_id => affiliate.id)
        SaytSuggestion.create!(:phrase => 'eliz aaa', :popularity => 100, :affiliate_id => affiliate.id)
        SaytSuggestion.create!(:phrase => 'eliz ggg', :popularity => 100, :affiliate_id => affiliate.id)
      end

      it 'should return results in alphabetical order' do
        suggestions = SaytSuggestion.fetch_by_affiliate_id(affiliate.id, 'eliz', 3)
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
      @dummy_suggestion = SaytSuggestion.create(:phrase => 'dummy suggestions')
    end

    it 'should create SAYT suggestions using the affiliate provided, if provided' do
      @phrases.each do |phrase|
        expect(SaytSuggestion).to receive(:create).with({:phrase => phrase, :affiliate => @affiliate, :is_protected => true, :popularity => SaytSuggestion::MAX_POPULARITY}).and_return @dummy_suggestion
      end
      SaytSuggestion.process_sayt_suggestion_txt_upload(@file, @affiliate)
    end
  end

  describe '#to_label' do
    it 'should return the phrase' do
      expect(SaytSuggestion.new(:phrase => 'dummy suggestion', :affiliate => @affiliate).to_label).to eq('dummy suggestion')
    end
  end

  describe '#related_search' do
    before do
      @affiliate = affiliates(:basic_affiliate)
      SaytSuggestion.destroy_all
      SaytSuggestion.create!(:affiliate_id => @affiliate.id, :phrase => 'suggest me', :popularity => 30)
      ElasticSaytSuggestion.commit
    end

    it 'should return an array of highlighted strings' do
      expect(SaytSuggestion.related_search('suggest', @affiliate)).to eq(['<strong>suggest</strong> me'])
    end

    context 'when affiliate has related searches disabled' do
      before do
        @affiliate.is_related_searches_enabled = false
      end

      it 'should return an empty array' do
        expect(SaytSuggestion.related_search('suggest', @affiliate)).to eq([])
      end
    end

  end
end
