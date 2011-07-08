require 'spec/spec_helper'

describe SpellcheckSaytSuggestions, "#perform(wrong,rite)" do
  fixtures :affiliates

  it "should apply the correction to existing SaytSuggestions" do
    phrase = "only one c is necccessary"
    SaytSuggestion.create!(:phrase => phrase)
    wrong = "necccessary"
    rite = "necessary"
    Misspelling.create!(:wrong=> wrong, :rite=>rite)
    SpellcheckSaytSuggestions.perform(wrong, rite)
    SaytSuggestion.find_by_phrase(phrase).should be_nil
    SaytSuggestion.find_by_phrase("only one c is necessary").should_not be_nil
  end

  it "should not apply the correction to existing SaytSuggestions that belong to an affiliate" do
    SaytSuggestion.create!(:phrase => "haus", :affiliate => affiliates(:basic_affiliate))
    wrong = "haus"
    rite = "house"
    Misspelling.create!(:wrong=> wrong, :rite=>rite)
    SpellcheckSaytSuggestions.perform(wrong, rite)
    SaytSuggestion.find_by_phrase("haus").should_not be_nil
  end
end
