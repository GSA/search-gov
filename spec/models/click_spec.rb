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
end
