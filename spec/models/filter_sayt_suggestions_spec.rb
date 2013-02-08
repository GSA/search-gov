require 'spec_helper'

describe FilterSaytSuggestions, "#perform(id)" do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
    @phrase = "ought to get deleted xxx"
    SaytSuggestion.create!(:affiliate => @affiliate, :phrase => @phrase)
  end

  it "should run the filter against existing SaytSuggestions" do
    sf = SaytFilter.create!(:phrase => "xxx")
    FilterSaytSuggestions.perform(sf.id)
    SaytSuggestion.find_by_phrase(@phrase).should be_nil
  end

  it "should Regexp escape the filter before applying it" do
    sf = SaytFilter.create!(:phrase => "ought.")
    FilterSaytSuggestions.perform(sf.id)
    SaytSuggestion.find_by_phrase(@phrase).should_not be_nil
  end

  context "after saving a SaytFilter with filter_only_exact_entry is true" do
    before do
      @should_be_deleted_phrase = "xxx"
      SaytSuggestion.create!(:affiliate => @affiliate, :phrase => @should_be_deleted_phrase)
      @should_not_be_deleted_phrase = "should not be deleted xxx"
      SaytSuggestion.create!(:affiliate => @affiliate, :phrase => @should_not_be_deleted_phrase)
    end

    it "should run the filter against existing SaytSuggestions" do
      sf = SaytFilter.create!(:phrase => "xxx", :filter_only_exact_phrase => true)
      FilterSaytSuggestions.perform(sf)
      SaytSuggestion.find_by_phrase(@should_be_deleted_phrase).should be_nil
      SaytSuggestion.find_by_phrase(@should_not_be_deleted_phrase).should_not be_nil
    end
  end

  context "when filter is a whitelist" do
    before do
      SaytSuggestion.create!(:affiliate => @affiliate, :phrase => 'sex education')
    end

    let(:whitelist_filter) { SaytFilter.create!(:phrase => "sex education", :accept => true) }

    it 'should not do anything to the sayt suggestions' do
      FilterSaytSuggestions.perform(whitelist_filter)
      SaytSuggestion.find_by_phrase('sex education').should be_present
    end
  end
end