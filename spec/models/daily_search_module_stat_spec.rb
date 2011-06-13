require 'spec/spec_helper'

describe DailySearchModuleStat do
  fixtures :daily_search_module_stats, :search_modules, :affiliates

  before(:each) do
    @valid_attributes = {
      :day => Date.current,
      :module_tag => search_modules(:video),
      :vertical => "recall",
      :locale => 'en',
      :affiliate_name => affiliates(:power_affiliate),
      :impressions => 100,
      :clicks => 10
    }
  end

  describe "Creating new instance" do
    it { should validate_presence_of :day }
    it { should validate_presence_of :module_tag }
    it { should validate_presence_of :vertical }
    it { should validate_presence_of :locale }
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

  describe "#module_stats_for_day(day)" do
    context "when stats are available for the day" do
      before do
        impressions, clicks = 100, 10
        %w{usasearch.gov nps noaa}.each do |affiliate_name|
          %w{en es}.each do |locale|
            %w{VIDEO BWEB CREL}.each do |tag|
              %w{web recall image form}.each do |vertical|
                DailySearchModuleStat.create!(:day => Date.current, :module_tag => tag, :vertical => vertical,
                                              :locale => locale, :affiliate_name => affiliate_name, :impressions => impressions, :clicks => clicks)
                impressions, clicks = impressions + 17, clicks + 7
              end
            end
          end
        end
      end

      it "should return collection of structures grouped by module ordered by descending impression count that respond to display_name, impressions, clicks, clickthru_ratio" do
        stats = DailySearchModuleStat.module_stats_for_day(Date.current)
        stats[0].display_name.should == search_modules(:crel).display_name
        stats[0].impressions.should == 18516
        stats[0].clicks.should == 6876
        stats[0].clickthru_ratio.should be_within(0.001).of(37.135)

        stats[1].display_name.should == search_modules(:bweb).display_name
        stats[1].impressions.should == 16884
        stats[1].clicks.should == 6204
        stats[1].clickthru_ratio.should be_within(0.001).of(36.744)

        stats[2].display_name.should == search_modules(:video).display_name
        stats[2].impressions.should == 15252
        stats[2].clicks.should == 5532
        stats[2].clickthru_ratio.should be_within(0.001).of(36.270)
      end

      context "when search module stats references a non-existent search module name" do
        before do
          DailySearchModuleStat.create!(:day => Date.current, :module_tag => "LOREN", :vertical => "web", :locale => "en", :affiliate_name => "nps", :impressions => 1, :clicks => 1)
        end

        it "should not include that module tag in the results" do
          DailySearchModuleStat.module_stats_for_day(Date.current).count.should == 3
        end
      end
    end

    context "when no stats are available for the day" do
      before do
        DailySearchModuleStat.delete_all
      end

      it "should return an empty array" do
        DailySearchModuleStat.module_stats_for_day(Date.tomorrow).should == []
      end
    end
  end
end
