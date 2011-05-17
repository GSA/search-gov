require 'spec/spec_helper'

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
      
    it { should belong_to :affiliate }
    it { should validate_presence_of :day }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
    it { should validate_presence_of :time_frame }
    it { should validate_uniqueness_of(:query).scoped_to([:day, :affiliate_id, :is_grouped, :time_frame]) }
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