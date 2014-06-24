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
end
