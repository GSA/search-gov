require 'spec/spec_helper'

describe FilterSaytSuggestions, "#perform(phrase)" do
  before do
    @phrase = "ought to get deleted xxx"
    SaytSuggestion.create!(:phrase => @phrase)
  end

  it "should run the filter against existing SaytSuggestions" do
    SaytFilter.create!(:phrase => "xxx")
    FilterSaytSuggestions.perform("xxx")
    SaytSuggestion.find_by_phrase(@phrase).should be_nil
  end

  it "should Regexp escape the filter before applying it" do
    SaytFilter.create!(:phrase => "ought.")
    FilterSaytSuggestions.perform("ought.")
    SaytSuggestion.find_by_phrase(@phrase).should_not be_nil
  end

  context "after saving a SaytFilter with filter_only_exact_entry is true" do
    before do
      @should_be_deleted_phrase = "xxx"
      SaytSuggestion.create!(:phrase => @should_be_deleted_phrase)
      @should_not_be_deleted_phrase = "should not be deleted xxx"
      SaytSuggestion.create!(:phrase => @should_not_be_deleted_phrase)
    end

    it "should run the filter against existing SaytSuggestions" do
      SaytFilter.create!(:phrase => "xxx", :filter_only_exact_phrase => true)
      FilterSaytSuggestions.perform("xxx")
      SaytSuggestion.find_by_phrase(@should_be_deleted_phrase).should be_nil
      SaytSuggestion.find_by_phrase(@should_not_be_deleted_phrase).should_not be_nil
    end
  end
end
