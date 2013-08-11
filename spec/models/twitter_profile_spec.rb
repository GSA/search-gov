require 'spec_helper'

describe TwitterProfile do
  fixtures :affiliates

  before do
    Twitter.stub!(:user).and_return mock('Twitter', :id => 123, :name => 'USASearch', :profile_image_url => 'http://some.gov/url')
    @valid_attributes = {
      :twitter_id => 123,
      :screen_name => 'USASearch',
      :name => 'USASearch',
      :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png'
    }
  end

  it { should have_many :tweets }
  it { should have_many :affiliates }
  it { should have_many(:affiliate_twitter_settings).dependent(:destroy) }
  it { should have_and_belong_to_many :twitter_lists }

  it { should validate_presence_of :screen_name }

  it 'must have valid screen_name' do
    Twitter.stub(:user).and_return(nil)
    profile = TwitterProfile.create(:screen_name => 'USASearch')
    profile.errors[:screen_name].should include('is invalid')
  end

  context "when screen_name has leading @" do
    it 'should normalize screen_name before validation' do
      tp = TwitterProfile.create!(@valid_attributes.merge(:screen_name => '@at_sign'))
      tp.screen_name.should == 'at_sign'
    end
  end

  context "when screen_name has trailing spaces" do
    it 'should normalize screen_name before validation' do
      tp = TwitterProfile.create!(@valid_attributes.merge(:screen_name => 'CDCSalud  '))
      tp.screen_name.should == 'CDCSalud'
    end
  end

  context 'when screen_name is valid' do
    let(:twitter_user) do
      mock('twitter user',
           :id => nil,
           :name => 'USASearch',
           :profile_image_url => nil)
    end
    subject { TwitterProfile.new(:screen_name => 'USASearch') }

    before { Twitter.stub(:user).and_return(twitter_user) }

    it { should validate_presence_of :twitter_id }
    it { should validate_presence_of :profile_image_url }
  end

  context 'when screen_name is invalid' do
    subject { TwitterProfile.new(:screen_name => 'USASearch') }

    before { Twitter.stub(:user).and_return(nil) }

    it { should_not validate_presence_of :twitter_id }
    it { should_not validate_presence_of :profile_image_url }
  end

  it "should create an instance with valid attributes" do
    TwitterProfile.create!(@valid_attributes)

    should validate_uniqueness_of(:twitter_id)
  end

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
      Twitter.should_receive(:user).exactly(3).times.and_raise "Some Error"
      TwitterProfile.create(:screen_name => "NewHandle").errors.should_not be_empty
    end

    it 'should not revalidate Twitter user when twitter_id, screen_name, name and profile_image_url are present' do
      Twitter.should_not_receive(:user)
      TwitterProfile.create!(twitter_id: 12,
                             screen_name: 'jack',
                             name: 'Jack D',
                             profile_image_url: 'http://twitter.com/profile.jpg')
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

  describe '.affiliate_twitter_ids' do
    let(:affiliate1) { affiliates(:usagov_affiliate) }
    let(:affiliate2) { affiliates(:gobiernousa_affiliate) }

    before do
      profile = TwitterProfile.new(twitter_id: 100, name: 'usasearch', profile_image_url: 'http://twitter.com/profile100.jpg')
      profile.save(validate: false)
      affiliate1.twitter_profiles << profile
      profile = TwitterProfile.new(twitter_id: 101, name: 'usasearchdev', profile_image_url: 'http://twitter.com/profile101.jpg')
      profile.save(validate: false)
      affiliate1.twitter_profiles << profile
      affiliate2.twitter_profiles << profile

      profile = TwitterProfile.new(twitter_id: 102, name: 'usagov', profile_image_url: 'http://twitter.com/profile102.jpg')
      profile.save(validate: false)
    end

    it 'should return twitter_ids that for profiles that belongs to an affiliate' do
      TwitterProfile.affiliate_twitter_ids.should == [100, 101]
    end
  end

  describe '.show_lists_enabled' do
    let(:affiliate1) { affiliates(:usagov_affiliate) }
    let(:affiliate2) { affiliates(:gobiernousa_affiliate) }

    before do
      profile = TwitterProfile.new(twitter_id: 100, name: 'usasearch', profile_image_url: 'http://twitter.com/profile100.jpg')
      profile.save(validate: false)
      affiliate1.twitter_profiles << profile
      affiliate1.affiliate_twitter_settings.find_by_twitter_profile_id(profile.id).update_attributes!(show_lists: 1)

      profile = TwitterProfile.new(twitter_id: 101, name: 'usasearchdev', profile_image_url: 'http://twitter.com/profile101.jpg')
      profile.save(validate: false)
      affiliate1.twitter_profiles << profile
      affiliate1.affiliate_twitter_settings.find_by_twitter_profile_id(profile.id).update_attributes!(show_lists: 1)
      affiliate2.twitter_profiles << profile
      affiliate2.affiliate_twitter_settings.find_by_twitter_profile_id(profile.id).update_attributes!(show_lists: 1)

      profile = TwitterProfile.new(twitter_id: 102, name: 'usagov', profile_image_url: 'http://twitter.com/profile102.jpg')
      profile.save(validate: false)
      affiliate2.twitter_profiles << profile
    end

    it 'should return affiliate profiles with show lists enabled' do
      profiles_with_show_lists_enabled = TwitterProfile.show_lists_enabled
      profiles_with_show_lists_enabled.should == [TwitterProfile.find_by_twitter_id(100), TwitterProfile.find_by_twitter_id(101)]
    end
  end
end
