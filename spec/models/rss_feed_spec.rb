require 'spec_helper'

describe RssFeed do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :navigations

  before do
    @valid_attributes = {
      :affiliate_id => affiliates(:basic_affiliate).id,
      :name => 'Blog',
      :rss_feed_urls_attributes => { '0' => { :url => 'http://usasearch.howto.gov/rss' } }
    }

    @attributes_with_some_blank_urls = {
        :affiliate_id => affiliates(:basic_affiliate).id,
        :name => 'Blog',
        :rss_feed_urls_attributes => { '0' => { :url => ' ' },
                                       '1' => { :url => 'http://usasearch.howto.gov/rss' } }
    }

    @attributes_with_all_blank_urls = {
        :affiliate_id => affiliates(:basic_affiliate).id,
        :name => 'Blog',
        :rss_feed_urls_attributes => { '0' => { :url => ' ' },
                                       '1' => { :url => ' ' } }
    }
  end

  it { should validate_presence_of :name }
  it { should validate_presence_of :affiliate_id }
  it { should belong_to :affiliate }
  it { should have_many(:rss_feed_urls).dependent(:destroy) }
  it { should have_many(:news_items).dependent(:destroy) }
  it { should_not allow_mass_assignment_of(:is_managed) }
  it { should_not allow_mass_assignment_of(:is_video) }


  context "on create" do
    before do
      rss_feed_content = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
      Kernel.stub(:open).with('http://usasearch.howto.gov/rss').and_return(rss_feed_content)
    end

    it "should create a new instance given valid attributes" do
      RssFeed.create!(@valid_attributes)
    end

    it "should create navigation" do
      rss_feed = RssFeed.create!(@valid_attributes)
      rss_feed.navigation.should == Navigation.find(rss_feed.navigation.id)
      rss_feed.navigation.affiliate_id.should == rss_feed.affiliate_id
      rss_feed.navigation.position.should == 100
      rss_feed.navigation.should_not be_is_active
    end

    it "should not allow RssFeed without RssFeedUrl attributes" do
      RssFeed.new(@valid_attributes.except(:rss_feed_urls_attributes)).save.should be_false
    end

    it "should not allow RssFeed with blank RssFeedUrl attributes" do
      RssFeed.new(@attributes_with_all_blank_urls).save.should be_false
    end

    it "should ignore blank RssFeedUrl attributes" do
      rss_feed = RssFeed.create!(@attributes_with_some_blank_urls)
      rss_feed.rss_feed_urls.count.should == 1
      rss_feed.rss_feed_urls.first.url.should == 'http://usasearch.howto.gov/rss'
    end

    it "should set shown_in_govbox to false by default" do
      RssFeed.create!(@valid_attributes).shown_in_govbox.should be_false
    end

    context "when the RSS feed is a valid feed" do
      before do
        rss = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
        Kernel.stub!(:open).and_return rss
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
        Kernel.stub!(:open).and_return rss
      end

      it "should not validate" do
        rss_feed = RssFeed.new(@valid_attributes)
        rss_feed.valid?.should be_false
        rss_feed.errors.should_not be_empty
      end
    end

    context "when some error is raised in checking the RSS feed" do
      before do
        Kernel.stub!(:open).and_raise 'Some exception'
      end

      it "should not validate" do
        rss_feed = RssFeed.new(@valid_attributes)
        rss_feed.valid?.should be_false
        rss_feed.errors.should_not be_empty
      end
    end
  end

  context "on save" do
    it "should not save when all RssFeedUrl are marked for destruction" do
      blog = rss_feeds(:white_house_blog)
      rss_feed_url = blog.rss_feed_urls.first
      blog.update_attributes(:rss_feed_urls_attributes => { '0' => { :id => rss_feed_url.id,
                                                                     :url => rss_feed_url.url,
                                                                     :_destroy => '1'} }).should be_false
    end
  end

  describe '.refresh_managed_feeds' do
    it 'should freshen managed feeds with the most news items first' do
      feed_with_most_news_items = mock_model(RssFeed)
      feed_with_most_news_items.stub_chain(:news_items, :count).and_return(3001)

      feed_with_some_news_items = mock_model(RssFeed)
      feed_with_some_news_items.stub_chain(:news_items, :count).and_return(90)

      feed_with_few_news_items = mock_model(RssFeed)
      feed_with_few_news_items.stub_chain(:news_items, :count).and_return(8)

      managed_feeds = [feed_with_few_news_items,
                       feed_with_most_news_items,
                       feed_with_some_news_items]

      RssFeed.stub_chain(:managed, :updated_before).and_return(managed_feeds)
      feed_with_most_news_items.should_receive(:touch)
      Resque.should_receive(:enqueue_with_priority).
          with(:high, RssFeedFetcher, [feed_with_most_news_items.id])

      RssFeed.refresh_managed_feeds
    end

    it 'should enqueue as many managed feeds within limit' do
      feed_with_most_news_items = mock_model(RssFeed)
      feed_with_most_news_items.stub_chain(:news_items, :count).and_return(2950)

      feed_with_some_news_items = mock_model(RssFeed)
      feed_with_some_news_items.stub_chain(:news_items, :count).and_return(45)

      feed_with_few_news_items = mock_model(RssFeed)
      feed_with_few_news_items.stub_chain(:news_items, :count).and_return(8)

      managed_feeds = [feed_with_few_news_items,
                       feed_with_most_news_items,
                       feed_with_some_news_items]

      RssFeed.stub_chain(:managed, :updated_before).and_return(managed_feeds)
      feed_with_most_news_items.should_receive(:touch).ordered
      feed_with_some_news_items.should_receive(:touch).ordered

      Resque.should_receive(:enqueue_with_priority).
          with(:high, RssFeedFetcher, [feed_with_most_news_items.id, feed_with_some_news_items.id])
      RssFeed.refresh_managed_feeds
    end
  end

  describe '.refresh_non_managed_feeds' do
    it 'should enqueue all non managed feeds' do
      rss_feed1 = mock_model(RssFeed)
      rss_feed2 = mock_model(RssFeed)
      RssFeed.stub_chain(:where, :order).and_return([rss_feed1, rss_feed2])
      rss_feed1.should_receive(:freshen)
      rss_feed2.should_receive(:freshen)
      RssFeed.refresh_non_managed_feeds
    end
  end

  describe '#freshen' do
    it 'should enqueue RssFeedFetcher' do
      rss_feed = rss_feeds(:basic)
      Resque.should_receive(:enqueue_with_priority).with(:high, RssFeedFetcher, rss_feed.id, nil, true)
      rss_feed.freshen
    end
  end

  describe "#is_video?" do
    let(:affiliate) { affiliates(:power_affiliate) }

    context "when each RssFeedUrl is video" do
      let(:rss_feed) do
        affiliate.rss_feeds.create!(:name => 'Videos',
                                    :rss_feed_urls_attributes => { '0' => { :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=USGovernment' },
                                                                   '1' => { :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse' } })
      end

      let(:youtube_xml) { File.read(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml') }

      before do
        Kernel.stub(:open) do |arg|
          case arg
          when %r[^http://gdata.youtube.com/feeds/base/videos] then youtube_xml
          end
        end
      end

      specify { rss_feed.should be_is_video }
    end

    context "when at least one RssFeedUrl is not video" do
      let(:rss_feed) do
        affiliate.rss_feeds.create!(:name => 'Not only videos',
                                    :rss_feed_urls_attributes => { '0' => { :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=USGovernment' },
                                                                   '1' => { :url => 'http://usasearch.howto.gov/rss' } })
      end

      before do
        video_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        Kernel.stub(:open).with('http://gdata.youtube.com/feeds/base/videos?alt=rss&author=USGovernment').and_return(video_content)

        non_video_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
        Kernel.stub(:open).with('http://usasearch.howto.gov/rss').and_return(non_video_content)
      end

      specify { rss_feed.should_not be_is_video }
    end
  end
end
