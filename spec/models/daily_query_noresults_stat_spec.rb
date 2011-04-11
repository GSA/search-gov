require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyQueryNoresultsStat do
  fixtures :daily_query_noresults_stats
  before(:each) do
    @valid_attributes = {
      :day => Date.today,
      :query => "nothing found",
      :times => 11,
      :affiliate => Affiliate::USAGOV_AFFILIATE_NAME,
      :locale => I18n.default_locale.to_s
    }
  end

  describe 'validations on create' do
    should_validate_presence_of(:day, :query, :times, :affiliate, :locale)
    should_validate_uniqueness_of :query, :scope => [:day, :affiliate, :locale]

    it "should create a new instance given valid attributes" do
      DailyQueryNoresultsStat.create!(@valid_attributes)
    end
  end
end
