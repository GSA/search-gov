require "#{File.dirname(__FILE__)}/../spec_helper"
describe DailyQueryIpStat do
  before(:each) do
    @valid_attributes = {
      :query => "government",
      :ipaddr => "123.456.7.89",
      :times => 1,
      :day => Date.today,
      :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME,
      :locale => I18n.default_locale.to_s
    }
  end

  it "should create a new instance given valid attributes" do
    DailyQueryIpStat.create!(@valid_attributes)
  end

end
