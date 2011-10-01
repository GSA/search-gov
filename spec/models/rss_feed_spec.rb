require 'spec/spec_helper'

describe RssFeed do
  fixtures :affiliates, :rss_feeds
  before do
    @valid_attributes = {
      :url => 'http://www.whitehouse.gov/feed/blog/white-house',
      :name => "Blog",
      :affiliate_id => affiliates(:basic_affiliate).id
    }
  end

  it { should validate_presence_of :url }
  it { should validate_presence_of :name }
  it { should validate_presence_of :affiliate_id }
  it { should belong_to :affiliate }
  it { should have_many(:news_items).dependent(:destroy) }

  it "should create a new instance given valid attributes" do
    RssFeed.create!(@valid_attributes)
  end

  context "when creating" do
    context "when the RSS feed is a valid feed" do
      before do
        rss = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
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

  describe "#refresh_all" do
    before do
      @blog = rss_feeds(:white_house_blog)
      @gallery = rss_feeds(:white_house_press_gallery)
      RssFeed.stub!(:all).and_return([@blog, @gallery])
    end

    it "should call freshen on all feeds" do
      @blog.should_receive(:freshen).once
      @gallery.should_receive(:freshen).once
      RssFeed.refresh_all
    end
  end

  describe "#freshen" do
    let(:feed) { rss_feeds(:white_house_blog) }
    before do
      doc = Nokogiri::XML(open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml'))
      Nokogiri::XML::Document.should_receive(:parse).and_return(doc)
    end

    context "when there are no news items associated with the source" do
      before do
        feed.news_items.delete_all
      end

      it "should populate news items from the RSS feed source with HTML stripped from the description" do
        feed.freshen
        feed.reload
        feed.news_items.count.should == 3
        newest = feed.news_items.first
        newest.guid.should == "80731 at http://www.whitehouse.gov"
        newest.link.should == "http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution"
        newest.published_at.should == DateTime.parse("26 Sep 2011 21:33:05 +0000")
        newest.description[0,40].should == "Dr. Biden and David Letterman refer to a"
        newest.title.should == "Famine in the Horn of Africa: Be a Part of the Solution"
      end
    end

    context "when some news items are newer and some are older than the most recent published_at time for the feed" do
      before do
        NewsItem.delete_all
        NewsItem.create!(:link => 'http://www.whitehouse.gov/latest_story.html',
                         :title => "Big story here",
                         :description => "Corps volunteers have promoted blah blah blah.",
                         :published_at => DateTime.parse("26 Sep 2011 18:31:23 +0000"),
                         :guid => 'unique',
                         :rss_feed_id => feed.id
        )
      end

      it "should populate news items with the news ones from the RSS feed source based on the pubDate" do
        feed.freshen
        feed.news_items.count.should == 3
      end
    end

    context "when there are duplicate news items" do
      before do
        NewsItem.delete_all
        NewsItem.create!(:link => 'http://www.whitehouse.gov/latest_story.html',
                         :title => "Big story here",
                         :description => "Corps volunteers have promoted blah blah blah.",
                         :published_at => DateTime.parse("26 Sep 2011 18:31:21 +0000"),
                         :guid => '80653 at http://www.whitehouse.gov',
                         :rss_feed_id => feed.id
        )
      end

      it "should ignore them" do
        NewsItem.should_receive(:create).twice
        feed.freshen
      end
    end

    it "should commit the news items to Solr" do
      Sunspot.should_receive(:commit).once
      feed.freshen
    end
  end

end