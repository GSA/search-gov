require 'spec_helper'

describe DailyClickStat do
  fixtures :daily_click_stats, :affiliates
  before(:each) do
    @valid_attributes = {
      :affiliate => affiliates(:power_affiliate).name,
      :day => "20120320",
      :url => "http://www.nps.gov/news.php?x=9",
      :times => 314
    }
  end

  describe 'validations on create' do
    it { should validate_presence_of :affiliate }
    it { should validate_presence_of :day }
    it { should validate_presence_of :url }
    it { should validate_presence_of :times }
    it { should validate_uniqueness_of(:url).scoped_to([:day, :affiliate]) }

    it "should create a new instance given valid attributes" do
      DailyClickStat.create!(@valid_attributes)
    end
  end

  describe ".top_urls(affiliate_name, start_date, end_date, num_results)" do
    it "should return the num_results most popular clicked URLs for an affiliate in some date range" do
      num_results, start_date, end_date, affiliate_name = 20, Date.yesterday, Date.current, "foo"
      DailyClickStat.should_receive(:sum).with(:times, :group => :url, :order => "sum_times desc", :limit => num_results,
                                               :conditions => ['day between ? AND ? AND affiliate = ?', start_date, end_date, affiliate_name])
      DailyClickStat.top_urls(affiliate_name, start_date, end_date, num_results)
    end
  end
end
