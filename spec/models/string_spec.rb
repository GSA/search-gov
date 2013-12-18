# coding: utf-8
require 'spec_helper'

describe String do

  describe "#sentence_case" do
    it "should properly capitalize words in a sentence" do
      "Loren's visit to the CIA with O'Toole and al-Gaddafi wasn't fun, so I doubt he'll return.".sentence_case.should == "Loren's Visit to the CIA with O'Toole and al-Gaddafi Wasn't Fun, so I Doubt He'll Return."
      "Muammar al-Gaddafi".sentence_case.should == "Muammar al-Gaddafi"
    end
  end
end
