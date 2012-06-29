require 'spec/spec_helper'

describe TwitterProfile do
  before do
    @valid_attributes = {
      :twitter_id => 123,
      :screen_name => 'USASearch',
      :name => 'USASearch',
      :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png'
    }
  end

  it { should validate_presence_of :twitter_id }
  it { should validate_presence_of :screen_name }
  it { should validate_presence_of :profile_image_url }

  it "should create an instance with valid attributes" do
    TwitterProfile.create!(@valid_attributes)

    should validate_uniqueness_of :twitter_id
    should validate_uniqueness_of :screen_name
  end
  it { should have_many :tweets }
  it { should have_and_belong_to_many :affiliates }

  context "when creating a new TwitterProfile" do
    before do
      @twitter_user = mock(Object)
      @twitter_user.stub!(:id).and_return 123
      @twitter_user.stub!(:screen_name).and_return "NewHandle"
      @twitter_user.stub!(:name).and_return "Display name"
      @twitter_user.stub!(:profile_image_url).and_return "http://twitter.com/profile.jpg"
    end

    it "should use the Twitter API to find out the Twitter Profile id on create" do
      Twitter.should_receive(:user).with("NewHandle").and_return @twitter_user
      TwitterProfile.create!(:screen_name => "NewHandle").twitter_id.should == 123
    end

    it "should not create the profile if there is an error in using the Twitter API" do
      Twitter.should_receive(:user).and_raise "Some Error"
      TwitterProfile.create(:screen_name => "NewHandle").errors.should_not be_empty
    end
  end

  describe "#link_to_profile" do
    before do
      @profile = TwitterProfile.create!(@valid_attributes)
    end

    it "should output a properly formatted link to the tweet" do
      @profile.link_to_profile.should == 'http://twitter.com/USASearch'
    end
  end
end
