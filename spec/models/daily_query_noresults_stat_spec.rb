require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyQueryNoresultsStat do
  fixtures :daily_query_noresults_stats
  before(:each) do
    @valid_attributes = {
      :day => Date.current,
      :query => "nothing found",
      :times => 11,
      :affiliate => Affiliate::USAGOV_AFFILIATE_NAME,
      :locale => I18n.default_locale.to_s
    }
  end

  describe 'validations on create' do
    it { should validate_presence_of :day }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
    it { should validate_presence_of :affiliate }
    it { should validate_presence_of :locale }
    it { should validate_uniqueness_of(:query).scoped_to([:day, :affiliate, :locale]) }

    it "should create a new instance given valid attributes" do
      DailyQueryNoresultsStat.create!(@valid_attributes)
    end
  end
end
