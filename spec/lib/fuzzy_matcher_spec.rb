require 'spec_helper'

describe FuzzyMatcher do
  describe '#matches?' do
    let(:str1) { "diacritîcs" }
    let(:str2) { "diacritics" }

    it "should return true for close matches" do
      FuzzyMatcher.new(str1,str2).matches?.should be true
    end
  end
end
