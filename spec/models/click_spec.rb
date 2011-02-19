require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Click do
  before do
    @valid_attributes = {
      :query => "barack obama",
      :queried_at => DateTime.now,
      :clicked_at => DateTime.now,
      :url => 'http://www.whitehouse.gov/',
      :serp_position => 1,
      :results_source => 'BingResults',
      :affiliate => 'doi.gov'
    }
  end

  it "should create a new instance given valid attributes" do
    Click.create!(@valid_attributes)
  end

  should_validate_presence_of :queried_at, :url, :query, :results_source

  describe "#monthly_totals_for_affiliate" do
    it "should return total number of clicks for the given affiliate within the specified year and month" do
      year = 2011
      month = 1
      start_datetime = Date.new(year,month,1).to_time
      end_datetime = start_datetime + 1.month
      Click.should_receive(:count).with(:conditions => {:clicked_at => start_datetime..end_datetime, :affiliate => 'aff'})
      Click.monthly_totals_for_affiliate(year, month, 'aff')
    end
  end
end
