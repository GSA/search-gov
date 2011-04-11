require "#{File.dirname(__FILE__)}/../spec_helper"

describe DailyPopularQuery do
  fixtures :affiliates
  before do
    @valid_attributes = {
      :day => Date.yesterday,
      :locale => nil,
      :query => 'america',
      :times => 100,
      :is_grouped => false,
      :time_frame => 1
    }
  end
  
  describe "creating a new instance" do
    before do
      @daily_popular_query = DailyPopularQuery.create!(@valid_attributes)
    end
      
    should_belong_to :affiliate
    should_validate_presence_of :day, :query, :times, :time_frame
    should_validate_uniqueness_of :query, :scope => [:day, :affiliate_id, :is_grouped, :time_frame]  
  end
  
  describe "#most_recent_populated_date" do
    it "should return the most recent date entered into the table for nil affiliate and locale" do
      DailyPopularQuery.should_receive(:maximum).with(:day, :conditions => ['ISNULL(affiliate_id) AND locale=?', I18n.default_locale.to_s])
      DailyPopularQuery.most_recent_populated_date
    end

    it "should return the most recent date for an affiliate if an affiliate is passed in" do
      affiliate = affiliates(:basic_affiliate)
      DailyPopularQuery.should_receive(:maximum).with(:day, :conditions => ['affiliate_id=? AND locale=?', affiliate.id, I18n.default_locale.to_s])
      DailyPopularQuery.most_recent_populated_date(affiliate)
    end

    it "should return the most recent date for a locale if specified" do
      affiliate = affiliates(:basic_affiliate)
      DailyPopularQuery.should_receive(:maximum).with(:day, :conditions => ['affiliate_id=? AND locale=?', affiliate.id, 'es'])
      DailyPopularQuery.most_recent_populated_date(affiliate, 'es')
    end
  end
end