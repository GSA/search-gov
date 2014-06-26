# coding: utf-8
require 'spec_helper'

describe SaytSuggestionDiscovery, "#perform(affiliate_name, affiliate_id, date_int, limit)" do
  fixtures :misspellings, :affiliates

  let(:affiliate) { affiliates(:power_affiliate) }
  let(:date_int) { 20140626 }

  context "when searches with results exist for an affiliate" do
    before do
      RtuTopQueries.stub(:new).and_return mock(RtuTopQueries, top_n: [['today term1', 55], ['today term2', 54]])
    end

    it "should create unprotected suggestions" do
      SaytSuggestionDiscovery.perform(affiliate.name, affiliate.id, date_int, 10)
      SaytSuggestion.find_by_affiliate_id_and_phrase(affiliate.id, "today term1").is_protected.should be_false
    end

    it "should populate SaytSuggestions based on each DailyQueryStat for the given day" do
      SaytSuggestionDiscovery.perform(affiliate.name, affiliate.id, date_int, 10)
      SaytSuggestion.find_by_affiliate_id_and_phrase(affiliate.id, "today term1").should_not be_nil
      SaytSuggestion.find_by_affiliate_id_and_phrase(affiliate.id, "today term2").should_not be_nil
      SaytSuggestion.find_by_phrase("yesterday term1").should be_nil
    end

    context "when SaytSuggestion already exists for an affiliate" do
      before do
        SaytSuggestion.create!(:phrase => "today term1", :popularity => 17, :affiliate_id => affiliate.id)
      end

      it "should update the popularity field with the new count" do
        SaytSuggestionDiscovery.perform(affiliate.name, affiliate.id, date_int, 10)
        SaytSuggestion.find_by_affiliate_id_and_phrase(affiliate.id, "today term1").popularity.should == 55
      end
    end

    context "when suggestions exist that have been marked as deleted" do
      before do
        SaytSuggestion.create!(:phrase => 'today term1', :affiliate => affiliate, :deleted_at => Time.now, :is_protected => true, :popularity => SaytSuggestion::MAX_POPULARITY)
      end

      it "should not create a new suggestion, and leave the old suggestion alone" do
        SaytSuggestionDiscovery.perform(affiliate.name, affiliate.id, date_int, 10)
        suggestion = SaytSuggestion.find_by_affiliate_id_and_phrase(affiliate.id, "today term1")
        suggestion.deleted_at.should_not be_nil
        suggestion.popularity.should == SaytSuggestion::MAX_POPULARITY
      end
    end

    context "when SaytFilters exist" do
      before do
        SaytFilter.create!(phrase: "term2")
      end

      it "should apply SaytFilters to each eligible term" do
        SaytSuggestionDiscovery.perform(affiliate.name, affiliate.id, date_int, 10)
        SaytSuggestion.find_by_affiliate_id_and_phrase(affiliate.id, "today term2").should be_nil
      end
    end

    context "when computing for the current day" do
      before do
        Date.stub(:current).and_return Date.parse('2014-06-26')
        Time.stub!(:now).and_return Time.utc(2014, 6, 26, 8, 2, 1)
      end

      it "should factor in the time of day to compute a projected run rate for the term's popularity that day" do
        SaytSuggestionDiscovery.perform(affiliate.name, affiliate.id, date_int, 10)
        SaytSuggestion.find_by_affiliate_id_and_phrase(affiliate.id, "today term1").popularity.should == 164
      end
    end
  end
end
