# coding: utf-8
require 'spec_helper'

describe Misspelling do
  fixtures :misspellings, :affiliates

  describe 'Creating new instance' do

    it { is_expected.to validate_presence_of :wrong }
    it { is_expected.to validate_presence_of :rite }
    it { is_expected.to validate_uniqueness_of(:wrong).case_insensitive }
    it { is_expected.to validate_length_of(:wrong).is_at_least(3).is_at_most(80) }
    it { is_expected.not_to allow_value('two words').for(:wrong) }
    %w(wwwgsa.gov español).each do |value|
      it { is_expected.to allow_value(value).for(:wrong) }
    end

    it 'should create a new instance given valid attributes' do
      Misspelling.create!(:wrong => 'valueforwrong', :rite => 'value for rite')
    end

    it 'should strip whitespace from wrong/rite before inserting in DB' do
      wrong = ' leadingandtraleingwhitespaces '
      rite = ' leading and trailing whitespaces '
      misspelling = Misspelling.create!(:wrong => wrong, :rite => rite)
      expect(misspelling.wrong).to eq(wrong.strip)
      expect(misspelling.rite).to eq(rite.strip)
    end

    it 'should downcase wrong/rite before entering into DB' do
      upcased = 'CAPS'
      Misspelling.create!(:wrong => upcased, :rite => upcased)
      expect(Misspelling.find_by_wrong('caps').rite).to eq('caps')
    end

    it 'should squish multiple whitespaces between words in rite before entering into DB' do
      wrong = 'twospayces'
      rite = 'two  spaces'
      misspelling = Misspelling.create!(:wrong=> wrong, :rite=>rite)
      expect(misspelling.wrong).to eq('twospayces')
      expect(misspelling.rite).to eq('two spaces')
    end

    it 'should enqueue the spellchecking of SaytSuggestions via Resque' do
      ResqueSpec.reset!
      expect(Resque).to receive(:enqueue_with_priority).with(:high, SpellcheckSaytSuggestions, 'valueforwrong', 'value for rite')
      Misspelling.create!(:wrong => 'valueforwrong', :rite => 'value for rite')
    end

  end

  describe '#correct(phrase)' do
    it 'should return the phrase with words spelling-corrected' do
      expect(Misspelling.correct('barack ubama')).to eq('barack obama')
    end

    it 'should return nil if phrase is nil' do
      expect(Misspelling.correct(nil)).to be_nil
    end
  end

end
