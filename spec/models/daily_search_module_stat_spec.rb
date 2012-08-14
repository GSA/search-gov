require 'spec_helper'

describe DailySearchModuleStat do
  fixtures :daily_search_module_stats, :search_modules, :affiliates

  before(:each) do
    @valid_attributes = {
      :day => Date.current,
      :module_tag => search_modules(:video),
      :vertical => "recall",
      :locale => 'en',
      :affiliate_name => affiliates(:power_affiliate).name,
      :impressions => 100,
      :clicks => 10
    }
  end

  describe "Creating new instance" do
    it { should validate_presence_of :day }
    it { should validate_presence_of :module_tag }
    it { should validate_presence_of :vertical }
    it { should validate_presence_of :affiliate_name }
    it { should validate_presence_of :impressions }
    it { should validate_presence_of :clicks }
    it { should validate_uniqueness_of(:module_tag).scoped_to([:day, :affiliate_name, :locale, :vertical]) }
    it { should belong_to :search_module }

    it "should create a new instance given valid attributes" do
      DailySearchModuleStat.create!(@valid_attributes)
    end
  end

  describe "#most_recent_populated_date" do
    context "when data for multiple days exists" do
      before do
        DailySearchModuleStat.create!(@valid_attributes)
        DailySearchModuleStat.create!(@valid_attributes.merge(:day => Date.yesterday))
      end

      it "should return the most recent date" do
        DailySearchModuleStat.most_recent_populated_date.should == Date.current
      end
    end

    context "when table is empty" do
      before do
        DailySearchModuleStat.delete_all
      end

      it "should return nil" do
        DailySearchModuleStat.most_recent_populated_date.should be_nil
      end
    end
  end

  describe "#module_stats_for_daterange_and_affiliate_and_locale(daterange, affiliate_name, vertical)" do
    context "when at least some stats are available for the range" do
      before do
        DailySearchModuleStat.delete_all
        impressions, clicks = 100, 10
        (@range = Date.yesterday..Date.current).each do |day|
          %w{usasearch.gov nps noaa}.each do |affiliate_name|
            %w{VIDEO BWEB CREL}.each do |tag|
              %w{web recall image form}.each do |vertical|
                DailySearchModuleStat.create!(:day => day, :module_tag => tag, :vertical => vertical,
                                              :affiliate_name => affiliate_name, :impressions => impressions, :clicks => clicks)
                impressions, clicks = impressions + 17, clicks + 7
              end
            end
          end
        end
      end

      it "should return collection of structures including all verticals/affiliates, grouped by module, summed over the date range, ordered by descending impression count that respond to display_name, impressions, clicks, clickthru_ratio, and historical_ctr" do
        stats = DailySearchModuleStat.module_stats_for_daterange(@range)
        stats[0].display_name.should == search_modules(:crel).display_name
        stats[0].impressions.should == 18516
        stats[0].clicks.should == 6876
        stats[0].clickthru_ratio.should be_within(0.001).of(37.135)
        stats[0].historical_ctr[0].should be_within(0.001).of(34.479)
        stats[0].historical_ctr[1].should be_within(0.001).of(38.283)

        stats[1].display_name.should == search_modules(:bweb).display_name
        stats[1].impressions.should == 16884
        stats[1].clicks.should == 6204
        stats[1].clickthru_ratio.should be_within(0.001).of(36.744)
        stats[1].historical_ctr[0].should be_within(0.001).of(33.333)
        stats[1].historical_ctr[1].should be_within(0.001).of(38.088)

        stats[2].display_name.should == search_modules(:video).display_name
        stats[2].impressions.should == 15252
        stats[2].clicks.should == 5532
        stats[2].clickthru_ratio.should be_within(0.001).of(36.270)
        stats[2].historical_ctr[0].should be_within(0.001).of(31.714)
        stats[2].historical_ctr[1].should be_within(0.001).of(37.865)

        stats[3].display_name.should == "Total"
        stats[3].impressions.should == 50652
        stats[3].clicks.should == 18612
        stats[3].clickthru_ratio.should be_within(0.001).of(36.744)
        stats[3].historical_ctr[0].should be_within(0.001).of(33.333)
        stats[3].historical_ctr[1].should be_within(0.001).of(38.088)
      end

      context "when locale/vertical/affiliate are specified" do
        it "should return collection of structures filtered by vertical/affiliate, grouped by module, summed over the date range, ordered by descending impression count that respond to display_name, impressions, clicks, clickthru_ratio" do
          stats = DailySearchModuleStat.module_stats_for_daterange(@range, "usasearch.gov", "web")
          stats[0].display_name.should == search_modules(:crel).display_name
          stats[0].impressions.should == 1084
          stats[0].clicks.should == 384
          stats[0].clickthru_ratio.should be_within(0.001).of(35.424)
          stats[0].historical_ctr[0].should be_within(0.001).of(27.966)
          stats[0].historical_ctr[1].should be_within(0.001).of(37.5)

          stats[1].display_name.should == search_modules(:bweb).display_name
          stats[1].impressions.should == 948
          stats[1].clicks.should == 328
          stats[1].clickthru_ratio.should be_within(0.001).of(34.599)
          stats[1].historical_ctr[0].should be_within(0.001).of(22.619)
          stats[1].historical_ctr[1].should be_within(0.001).of(37.179)

          stats[2].display_name.should == search_modules(:video).display_name
          stats[2].impressions.should == 812
          stats[2].clicks.should == 272
          stats[2].clickthru_ratio.should be_within(0.001).of(33.497)
          stats[2].historical_ctr[0].should be_within(0.001).of(10.0)
          stats[2].historical_ctr[1].should be_within(0.001).of(36.797)

          stats[3].display_name.should == "Total"
          stats[3].impressions.should == 2844
          stats[3].clicks.should == 984
          stats[3].clickthru_ratio.should be_within(0.001).of(34.599)
          stats[3].historical_ctr[0].should be_within(0.001).of(22.619)
          stats[3].historical_ctr[1].should be_within(0.001).of(37.179)
        end
      end

      context "when search module stats references a non-existent search module name" do
        before do
          DailySearchModuleStat.create!(:day => @range.first, :module_tag => "LOREN", :vertical => "web", :affiliate_name => "nps", :impressions => 1, :clicks => 1)
        end

        it "should not include that module tag in the results" do
          DailySearchModuleStat.module_stats_for_daterange(@range).collect(&:module_tag).should_not include("LOREN")
        end
      end
    end

    context "when no stats are available for the daterange" do
      before do
        DailySearchModuleStat.delete_all
      end

      it "should return an empty array" do
        DailySearchModuleStat.module_stats_for_daterange(Date.tomorrow..Date.tomorrow).should == []
      end
    end
  end
end
