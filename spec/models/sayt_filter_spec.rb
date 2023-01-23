require 'spec_helper'

describe SaytFilter do
  fixtures :sayt_filters

  describe 'Creating new instance' do
    it { is_expected.to validate_presence_of :phrase }
    it { is_expected.to validate_uniqueness_of(:phrase).case_insensitive }
    it 'should validate only one of filter_only_exact_phrase and is_regex is true' do
      expect(described_class.new(phrase: 'bAd woRd', filter_only_exact_phrase: true, is_regex: true)).not_to be_valid
    end

    it 'should strip whitespace from phrase before inserting in DB' do
      phrase = ' leading and trailing whitespaces '
      sf = described_class.create!(phrase: phrase, is_regex: false, filter_only_exact_phrase: true, accept: true)
      expect(sf.phrase).to eq(phrase.strip)
      expect(sf.accept).to be true
      expect(sf.is_regex).to be false
      expect(sf.filter_only_exact_phrase).to be true
    end

    it 'should create a new instance given valid attributes' do
      described_class.create!(phrase: 'some valid filter phrase')
    end

    it 'should default filter_only_exact_phrase to false' do
      expect(described_class.create!(phrase: 'some filter phrase').filter_only_exact_phrase).to be false
    end

    it 'should downcase the phrase before entering into DB' do
      described_class.create!(phrase: 'ALL CAPS')
      expect(described_class.find_by_phrase('all caps').phrase).to eq('all caps')
    end

    it 'should squish multiple whitespaces between words in the phrase before entering into DB' do
      described_class.create!(phrase: 'two  spaces')
      expect(described_class.find_by_phrase('two spaces').phrase).to eq('two spaces')
    end

    it 'should reapply filters to existing SaytSuggestions' do
      expect(Resque).to receive(:enqueue_with_priority).with(:low, ApplySaytFilters)
      described_class.create!(phrase: 'some valid filter phrase')
    end

  end

  describe 'destroying an instance' do
    it 'should reapply remaining filters to existing SaytSuggestions' do
      sf = described_class.create!(phrase: 'some valid filter phrase')
      expect(Resque).to receive(:enqueue_with_priority).with(:low, ApplySaytFilters)
      sf.destroy
    end
  end

  describe '#match?(target_phrase)' do
    context 'when the filter phrase is basic' do
      before do
        @filter = described_class.create!(phrase: '.com')
      end

      it "should filter 'google .com'" do
        expect(@filter.match?('google .com')).to be_truthy
      end

      it "should filter 'google.com'" do
        expect(@filter.match?('google.com')).to be_truthy
      end
    end

    context 'when the filter is a regex' do
      let(:filter) { described_class.create!(phrase: "[^aeiou].com", is_regex: true) }
      it 'should match based on the regex' do
        expect(filter.match?('gotvowels.com')).to be_truthy
        expect(filter.match?('oaeiuXcom')).to be_falsey
      end
    end

    context 'when the filter requires an exact match' do
      let(:filter) { described_class.create!(phrase: 'xxx', filter_only_exact_phrase: true) }
      it 'should filter exact matches only' do
        expect(filter.match?('xxx')).to be_truthy
        expect(filter.match?('xxxx')).to be_falsey
        expect(filter.match?('xxx the')).to be_falsey
      end
    end
  end

  describe '#filter(results, key=nil)' do
    before do
      described_class.create!(phrase: 'foo')
      described_class.create!(phrase: 'blat baz')
      described_class.create!(phrase: 'hyphenate-me')
      described_class.create!(phrase: 'sex.')
      described_class.create!(phrase: 'bAd woRd', filter_only_exact_phrase: true)
      @queries = ['bar Foo', 'bar blat', 'blat', 'baz blat', 'baz loren', 'food', 'sex education', 'Bad Word', "don't use bad word"]
      @results = @queries.collect { |q| {'somekey' => q} }
    end

    it 'should not filter out queries that contain blocked terms but do not end on a word boundary' do
      filtered_terms = described_class.filter(@results, 'somekey')
      expect(filtered_terms.detect { |ft| ft['somekey'] == 'food' }).not_to be_nil
    end

    it 'should Regexp escape the filter before applying it' do
      filtered_terms = described_class.filter(@results, 'somekey')
      expect(filtered_terms.detect { |ft| ft['somekey'] == 'sex education' }).not_to be_nil
    end

    context 'when filter_only_exact_phrase is true' do
      it 'should filter exact phrase' do
        filtered_terms = described_class.filter(@results, 'somekey')
        expect(filtered_terms.detect { |ft| ft['somekey'] == 'bad word' }).to be_nil
      end

      it 'should not filter phrase that is part of a longer phrase' do
        filtered_terms = described_class.filter(@results, 'somekey')
        expect(filtered_terms.detect { |ft| ft['somekey'] == "don't use bad word" }).not_to be_nil
      end
    end

    context 'when results list is nil' do
      it 'should return nil' do
        expect(described_class.filter(nil, 'somekey')).to be_nil
      end
    end

    context 'when SaytFilter table is empty' do
      it 'should return the same list' do
        described_class.delete_all
        expect(described_class.filter(@results, 'somekey').size).to eq(@results.size)
      end
    end

    context 'when no key is passed in' do
      it 'should operate on raw strings' do
        expect(described_class.filter(@queries)).to eq(described_class.filter(@results, 'somekey').pluck('somekey'))
      end
    end

    context 'when there are exact whitelisted entries' do
      before do
        @queries << 'loren foo bar' << 'loren foo bar blat'
        described_class.create!(accept: true, phrase: 'loren foo bar', filter_only_exact_phrase: true)
      end

      it 'should not filter them' do
        expect(described_class.filter(@queries)).to include('loren foo bar')
        expect(described_class.filter(@queries)).not_to include('loren foo bar blat')
      end
    end

    context 'when there are non-exact whitelisted entries' do
      before do
        @queries << 'loren foo' << 'loren foo bar'
        described_class.create!(accept: true, phrase: 'loren foo', filter_only_exact_phrase: false)
      end

      it 'should not filter them' do
        expect(described_class.filter(@queries)).to include('loren foo')
        expect(described_class.filter(@queries)).to include('loren foo bar')
      end
    end

    context 'when there are regex whitelisted entries' do
      before do
        @queries << 'snafoo' << 'snaxfoo'
        described_class.create!(accept: true, phrase: '^.{3}foo', is_regex: true)
        described_class.create!(phrase: 'foo$', is_regex: true)
      end

      it 'should not filter them' do
        expect(described_class.filter(@queries)).to include('snafoo')
        expect(described_class.filter(@queries)).not_to include('snaxfoo')
      end
    end

    context 'when there are only whitelisted filters and no deny filters' do
      before do
        described_class.create!(accept: true, phrase: 'only once')
      end

      it 'should not create duplicates' do
        expect(described_class.filter(['only once'])).to eq(['only once'])
      end
    end
  end

  describe '#to_label' do
    it 'should return the phrase' do
      expect(described_class.new(phrase: 'dummy filter').to_label).to eq('dummy filter')
    end
  end
end
