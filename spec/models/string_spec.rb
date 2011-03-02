require "#{File.dirname(__FILE__)}/../spec_helper"

describe String do
  describe "#fuzzily_matches?" do
    it "should return true" do
      "this.has-punctuation'and spaces ".fuzzily_matches?("thishaspunctuationandspaces").should be_true
    end
  end

  describe "#sentence_case" do
    it "should properly capitalize words in a sentence" do
      "Loren's visit to the CIA with O'Toole wasn't fun, so I doubt he'll return.".sentence_case.should == "Loren's Visit to the CIA with O'Toole Wasn't Fun, so I Doubt He'll Return."
    end
  end
end
