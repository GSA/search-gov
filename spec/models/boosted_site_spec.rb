require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BoostedSite do
  fixtures :affiliates
  before(:each) do
    @valid_attributes = {
      :url => "http://www.someaffiliate.gov/foobar",
      :title => "The foobar page",
      :description => "All about foobar, boosted to the top",
      :affiliate => affiliates(:power_affiliate)
    }
  end

  describe "Creating new instance of BoostedSite" do
    should_validate_presence_of :url, :title, :description
    should_belong_to :affiliate

    it "should create a new instance given valid attributes" do
      BoostedSite.create!(@valid_attributes)
    end
  end

end
