require 'spec_helper'

describe FuzzyMatcher do
  describe '#matches?' do
    let(:str1) { "this.has-punctuation'and spaces and diacritîcs" }
    let(:str2) { "thishaspunctuationandspaces añd diacritics" }

    it "should return true for close matches" do
      FuzzyMatcher.new(str1,str2).matches?.should be_true
    end
  end
end
