require 'spec/spec_helper'

describe DailyLeftNavStat do
  fixtures :affiliates
  before(:each) do
    @valid_attributes = {
      :affiliate => affiliates(:power_affiliate),
      :day => "20120320",
      :search_type => "/search/news",
      :params => "NULL:y",
      :total => 314
    }
  end

  describe 'validations on create' do
    it { should validate_presence_of :affiliate_id }
    it { should validate_presence_of :day }
    it { should validate_presence_of :search_type }
    it { should validate_presence_of :total }
    it { should belong_to :affiliate }

    it "should create a new instance given valid attributes" do
      DailyLeftNavStat.create!(@valid_attributes)
    end
  end

  describe "#most_recent_populated_date(affiliate)" do
    it "should return the most recent date for a given affiliate" do
      DailyLeftNavStat.should_receive(:maximum).with(:day, :conditions => ['affiliate_id = ?', affiliates(:power_affiliate).id])
      DailyLeftNavStat.most_recent_populated_date(affiliates(:power_affiliate))
    end
  end

  describe "#least_recent_populated_date(affiliate)" do
    it "should return the least recent date for a given affiliate" do
      DailyLeftNavStat.should_receive(:minimum).with(:day, :conditions => ['affiliate_id = ?', affiliates(:power_affiliate).id])
      DailyLeftNavStat.least_recent_populated_date(affiliates(:power_affiliate))
    end
  end

  describe "#available_dates_range(affiliate)" do
    context "when there is no data in the table" do
      before do
        DailyLeftNavStat.delete_all
      end
      it "should return yesterday..yesterday" do
        DailyLeftNavStat.available_dates_range(affiliates(:power_affiliate)).should == (Date.yesterday..Date.yesterday)
      end
    end

    context "when there is data in the table" do
      before do
        @affiliate = affiliates(:power_affiliate)
        @affiliate.daily_left_nav_stats.create!(:day => Date.parse("2012-02-28"), :search_type => "/search/docs", :params => "7", :total => 99)
        @affiliate.daily_left_nav_stats.create!(:day => Date.parse("2012-03-03"), :search_type => "/search/news", :params => "66:y", :total => 29)
      end

      it "should return the range of dates available containing left nav stats for this affiliate" do
        DailyLeftNavStat.available_dates_range(@affiliate).should == (Date.parse("2012-02-28")..Date.parse("2012-03-03"))
      end
    end
  end

  describe "#bulk_load(file_path, day_str)" do
    it "should load the ctrl-A-delimited file to create DailyLeftNavStat records for a given day" do
      DailyLeftNavStat.bulk_load(Rails.root.to_s + "/spec/fixtures/txt/left_hand_nav_stats.txt", "20120229")
      DailyLeftNavStat.select("distinct affiliate_id").count.should == 2
      day = Date.parse "2012-02-29"
      gob = affiliates(:gobiernousa_affiliate)
      gob.daily_left_nav_stats.find_by_day_and_search_type_and_total_and_params(day, '/search', 355, nil).should_not be_nil
      gob.daily_left_nav_stats.find_by_day_and_search_type_and_total_and_params(day, '/search/images', 21, nil).should_not be_nil
      gob.daily_left_nav_stats.find_by_day_and_search_type_and_total_and_params(day, '/search/docs', 7, "3").should_not be_nil
      gob.daily_left_nav_stats.find_by_day_and_search_type_and_total_and_params(day, '/search/news', 10, "148:NULL").should_not be_nil
      pow = affiliates(:power_affiliate)
      pow.daily_left_nav_stats.find_by_day_and_search_type_and_total_and_params(day, '/search/news', 1, "NULL:y").should_not be_nil
      pow.daily_left_nav_stats.find_by_day_and_search_type_and_total_and_params(day, '/search/news', 5, "101:d").should_not be_nil
    end
  end

  describe "#collect_to_json(affiliate, start_date, end_date)" do
    context "when data exists for the date range" do
      before do
        @affiliate = affiliates(:power_affiliate)
        @date1 = Date.parse("2012-02-27")
        @date2 = Date.parse("2012-02-28")
        col1 = @affiliate.document_collections.create!(:name => "Col 1")
        col2 = @affiliate.document_collections.create!(:name => "Col 2")
        rss1 = @affiliate.rss_feeds.create!(:name => "Feed 1", :rss_feed_urls_attributes => { :'0' => { :url => 'http://www.whitehouse.gov/feed/blog/white-house' } })
        rss2 = @affiliate.rss_feeds.create!(:name => "Feed 2", :rss_feed_urls_attributes => { :'0' => { :url => 'http://www.whitehouse.gov/feed/blog/white-house' } })
        @affiliate.daily_left_nav_stats.build(:day => @date1, :search_type => "/search", :total => 999)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search", :total => 1000)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/images", :total => 100)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/docs", :params => col1.id.to_s, :total => 10)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/docs", :params => col2.id.to_s, :total => 1)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/news", :params => "#{rss1.id.to_s}:NULL", :total => 16)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/news", :params => "#{rss1.id.to_s}:d", :total => 8)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/news", :params => "#{rss1.id.to_s}:y", :total => 4)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/news", :params => "#{rss2.id.to_s}:NULL", :total => 17)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/news", :params => "#{rss2.id.to_s}:h", :total => 9)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/news", :params => "#{rss2.id.to_s}:m", :total => 3)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/news", :params => "NULL:h", :total => 47)
        @affiliate.daily_left_nav_stats.build(:day => @date2, :search_type => "/search/news", :params => "NULL:y", :total => 7)
        @affiliate.save!
      end

      it "should return the appropriate JSON-ish string to display in a jqtree" do
        expected = "[{\"label\":\"Web: 1999\"}," +
          "{\"label\":\"Images: 100\"}," +
          "{\"children\":[{\"label\":\"Col 1: 10\"},{\"label\":\"Col 2: 1\"}],\"label\":\"Docs\"}," +
          "{\"children\":[{\"children\":[{\"label\":\"Last Hour: 47\"},{\"label\":\"Last Year: 7\"}],\"label\":\"Everything\"}," +
          "{\"children\":[{\"label\":\"All Time: 17\"},{\"label\":\"Last Hour: 9\"},{\"label\":\"Last Month: 3\"}],\"label\":\"Feed 2\"}," +
          "{\"children\":[{\"label\":\"All Time: 16\"},{\"label\":\"Last Day: 8\"},{\"label\":\"Last Year: 4\"}],\"label\":\"Feed 1\"}]," +
          "\"label\":\"News\"}]"
        jsonish = DailyLeftNavStat.collect_to_json(@affiliate, @date1, @date2)
        json = "[" + jsonish + "]"
        ActiveSupport::JSON.decode(json).should == ActiveSupport::JSON.decode(expected)
      end
    end
  end
end
