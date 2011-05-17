require 'spec/spec_helper'

describe String do
  describe "#fuzzily_matches?" do
    it "should return true" do
      "this.has-punctuation'and spaces ".fuzzily_matches?("thishaspunctuationandspaces").should be_true
    end
  end

  describe "#sentence_case" do
    it "should properly capitalize words in a sentence" do
      "Loren's visit to the CIA with O'Toole and al-Gaddafi wasn't fun, so I doubt he'll return.".sentence_case.should == "Loren's Visit to the CIA with O'Toole and al-Gaddafi Wasn't Fun, so I Doubt He'll Return."
      "Muammar al-Gaddafi".sentence_case.should == "Muammar al-Gaddafi"
    end
  end
end
