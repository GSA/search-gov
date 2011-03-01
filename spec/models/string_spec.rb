require "#{File.dirname(__FILE__)}/../spec_helper"

describe String do
  describe "#fuzzily_matches?" do
    it "should return true" do
      "this.has-punctuation'and spaces ".fuzzily_matches?("thishaspunctuationandspaces").should be_true
    end
  end
end
