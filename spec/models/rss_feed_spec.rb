require 'spec_helper'

describe RssFeed do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :navigations

  before do
    @valid_attributes = {
        owner: affiliates(:basic_affiliate),
        name: 'Blog',
        rss_feed_urls: [RssFeedUrl.new(rss_feed_owner_type: 'Affiliate',
                                       url: 'http://usasearch.howto.gov/rss')] }
  end

  it { should validate_presence_of :name }
  it { should validate_presence_of :owner_id }
  it { should validate_presence_of :owner_type }
  it { should belong_to :owner }
  it { should have_and_belong_to_many :rss_feed_urls }
  it { should have_many(:news_items).through :rss_feed_urls }
  it { should_not allow_mass_assignment_of :is_video }
  it { should have_readonly_attribute :is_managed }


  context 'on create' do
    before do
      rss_feed_content = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
      HttpConnection.stub(:get).with('http://usasearch.howto.gov/rss').and_return(rss_feed_content)
    end

    it 'should create a new instance given valid attributes' do
      RssFeed.create!(@valid_attributes)
    end

    it "should create navigation for owner_type Affiliate" do
      rss_feed = RssFeed.create!(@valid_attributes)
      rss_feed.navigation.should == Navigation.find(rss_feed.navigation.id)
      rss_feed.navigation.affiliate_id.should == rss_feed.owner_id
      rss_feed.navigation.position.should == 100
      rss_feed.navigation.should_not be_is_active
    end

    it 'should not create navigation for other owner types' do
      username = 'thewhitehouse'.freeze
      uploaded_video_xml = File.read("#{Rails.root}/spec/fixtures/rss/youtube.xml")
      HttpConnection.should_receive(:get).with(YoutubeProfile.youtube_url(username)).
          and_return uploaded_video_xml

      owner = YoutubeProfile.create!(username: username)
      owner.rss_feed.navigation.should be_nil
    end

    context 'when is_managed is false' do
      it 'should require rss_feed_urls' do
        RssFeed.new(@valid_attributes.except(:rss_feed_urls)).save.should be_false
      end
    end

    context 'when is_managed is true' do
      it 'should not require rss_feed_urls' do
        rss_feed = RssFeed.new(@valid_attributes.except(:rss_feed_urls))
        rss_feed.is_managed = true
        rss_feed.should be_valid
      end
    end

    context "when the RSS feed is a valid feed" do
      before do
        rss = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
        HttpConnection.stub!(:get).and_return rss
      end

      it "should validate" do
        rss_feed = RssFeed.new(@valid_attributes)
        rss_feed.valid?.should be_true
        rss_feed.errors.should be_empty
      end
    end

    context "when the URL does not point to an RSS feed" do
      before do
        rss = File.read(Rails.root.to_s + '/spec/fixtures/html/usa_gov/site_index.html')
        HttpConnection.stub!(:get).and_return rss
      end

      it "should not validate" do
        rss_feed = RssFeed.new(@valid_attributes)
        rss_feed.valid?.should be_false
        rss_feed.errors.should_not be_empty
      end
    end

    context "when some error is raised in checking the RSS feed" do
      before do
        HttpConnection.stub!(:get).and_raise 'Some exception'
      end

      it "should not validate" do
        rss_feed = RssFeed.new(@valid_attributes)
        rss_feed.valid?.should be_false
        rss_feed.errors.should_not be_empty
      end
    end
  end

  context 'on save' do
    it 'should not save when url in rss_feed_urls are blank' do
      blog = rss_feeds(:white_house_blog)
      blog.rss_feed_urls.build(rss_feed_owner_type: 'Affiliate', url: '')
      blog.save.should be_false
      blog.errors.full_messages.should include('Rss feed url can\'t be blank')
    end
  end

  describe "#is_video?" do
    let(:affiliate) { affiliates(:power_affiliate) }

    context "when each RssFeedUrl is video" do
      let(:rss_feed) do
        affiliate.rss_feeds.create!(name: 'Videos',
                                    rss_feed_urls: [rss_feed_urls(:youtube_video_url), rss_feed_urls(:playlist_video_url)])
      end

      specify { rss_feed.should be_is_video }
    end

    context "when at least one RssFeedUrl is not video" do
      let(:rss_feed) do
        affiliate.rss_feeds.create!(name: 'Not only videos',
                                    rss_feed_urls: [rss_feed_urls(:youtube_video_url), rss_feed_urls(:white_house_press_gallery_url)])
      end

      specify { rss_feed.should_not be_is_video }
    end
  end
end
