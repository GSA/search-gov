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
  
  context "when the affiliate associated with a particular Boosted Site is destroyed" do
    fixtures :affiliates
    before do
      affiliate = Affiliate.create(:name => 'test_affiliate')
      BoostedSite.create(@valid_attributes.merge(:affiliate => affiliate))
      affiliate.destroy
    end
    
    it "should also delete the boosted site" do
      BoostedSite.find_by_url(@valid_attributes[:url]).should be_nil
    end
  end
  
  context "when the affiliate associated with a particular Boosted Site is deleted, and BoostedSites are reindexed" do
    fixtures :affiliates
    before do
      affiliate = Affiliate.create(:name => 'test_affiliate')
      BoostedSite.create(@valid_attributes.merge(:affiliate => affiliate))
      affiliate.delete
      BoostedSite.reindex
    end
    
    it "should not find the orphaned boosted site while searching for Search.USA.gov boosted sites" do
      BoostedSite.search_for("foobar").total.should == 0
    end
  end
end
