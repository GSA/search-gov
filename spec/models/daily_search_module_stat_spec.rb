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

end
