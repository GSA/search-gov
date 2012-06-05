require 'spec/spec_helper'

describe TwitterProfile do
  before do
    @valid_attributes = {
      :twitter_id => 123,
      :screen_name => 'USASearch',
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

  describe "#link_to_profile" do
    before do
      @profile = TwitterProfile.create!(@valid_attributes)
    end

    it "should output a properly formatted link to the tweet" do
      @profile.link_to_profile.should == "http://twitter.com/#!/USASearch"
    end
  end
end
