require 'spec/spec_helper'

describe YoutubeProfile do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:basic_affiliate)
    @valid_attributes = {
      :username => 'USAgency'
    }
  end
  
  it { should validate_presence_of :username }
  it { should validate_presence_of :affiliate }
  
  it "should create a new instance given valid attributes" do
    YoutubeProfile.create!(@valid_attributes.merge(:affiliate => @affiliate))
    should validate_uniqueness_of(:username).scoped_to(:affiliate_id)
  end
  
  it "should strip whitespace from the ends of the username" do
    profile = YoutubeProfile.create!(:username => '    whitehouse   ', :affiliate => @affiliate)
    profile.username.should == 'whitehouse'
  end
  
  it "should create a corresponding Video RSS feed on create" do
    @affiliate.rss_feeds.destroy_all
    @affiliate.rss_feeds.should be_empty
    profile = YoutubeProfile.create!(@valid_attributes.merge(:affiliate => @affiliate))
    @affiliate.reload
    @affiliate.rss_feeds.should_not be_empty
    @affiliate.rss_feeds.first.name.should == 'Videos'
    @affiliate.rss_feeds.first.rss_feed_urls.should_not be_empty
    @affiliate.rss_feeds.first.rss_feed_urls.first.url.should == profile.url
  end
  
  it "should add new YoutubeProfiles for the same affiliate to the Videos rss feed group if it exists" do
    @affiliate.rss_feeds.destroy_all
    @affiliate.rss_feeds.should be_empty
    profile = YoutubeProfile.create!(@valid_attributes.merge(:affiliate => @affiliate))
    @affiliate.reload
    @affiliate.rss_feeds.should_not be_empty
    @affiliate.rss_feeds.first.name.should == 'Videos'
    @affiliate.rss_feeds.first.rss_feed_urls.count.should == 1
    second_profile = YoutubeProfile.create!(:username => 'AnotherUSAgency', :affiliate => @affiliate)
    @affiliate.reload
    @affiliate.rss_feeds.count.should == 1
    @affiliate.rss_feeds.first.rss_feed_urls.count.should == 2
  end
  
  it "should delete associated rss feed when the profile is deleted" do
    @affiliate.rss_feeds.destroy_all
    profile = YoutubeProfile.create!(@valid_attributes.merge(:affiliate => @affiliate))
    profile.destroy
    @affiliate.reload
    @affiliate.rss_feeds.should be_empty
  end
  
  it "should update the associated rss feed if the username is changed" do
    @affiliate.rss_feeds.destroy_all
    profile = YoutubeProfile.create!(@valid_attributes.merge(:affiliate => @affiliate))
    profile.update_attributes(:username => 'America')
    @affiliate.reload
    @affiliate.rss_feeds.first.rss_feed_urls.first.url.should == profile.url
  end
  
  it "should delete only the specific feed if more than a single url is associated with a feed" do
    @affiliate.rss_feeds.destroy_all
    rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml').read
    Kernel.stub(:open).and_return(rss_feed_content)
    profile = YoutubeProfile.create!(@valid_attributes.merge(:affiliate => @affiliate))
    @affiliate.rss_feeds.find_by_name_and_is_managed('Videos', true).rss_feed_urls.create!(:url => 'http://something.else.com/rss.xml')
    profile.destroy
    @affiliate.reload
    @affiliate.rss_feeds.first.rss_feed_urls.count.should == 1
  end
end
