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
    it "should set is_navigable to false by default" do
      RssFeed.create!(@valid_attributes).is_navigable.should be_false
    end

    it "should set shown_in_govbox to false by default" do
      RssFeed.create!(@valid_attributes).shown_in_govbox.should be_false
    end

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
    context "when the feed is in the RSS 2.0 format" do
      before do
        @feed = rss_feeds(:white_house_blog)
        doc = Nokogiri::XML(open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml'))
        Nokogiri::XML::Document.should_receive(:parse).and_return(doc)
      end

      context "when there are no news items associated with the source" do
        before do
          @feed.news_items.delete_all
        end

        it "should populate news items from the RSS feed source with HTML stripped from the description" do
          @feed.freshen
          @feed.reload
          @feed.last_crawl_status.should == "OK"
          @feed.news_items.count.should == 3
          newest = @feed.news_items.first
          newest.guid.should == "80731 at http://www.whitehouse.gov"
          newest.link.should == "http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution"
          newest.published_at.should == DateTime.parse("26 Sep 2011 21:33:05 +0000")
          newest.description[0, 40].should == "Dr. Biden and David Letterman refer to a"
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
                           :rss_feed_id => @feed.id
          )
        end

        context "when ignore_older_items set to true (default)" do
          it "should populate news items with only the new ones from the RSS feed source based on the pubDate" do
            @feed.freshen
            @feed.news_items.count.should == 3
          end
        end

        context "when ignore_older_items set to false" do
          it "should populate news items with both the new and old ones from the RSS feed source based on the pubDate" do
            @feed.freshen(false)
            @feed.news_items.count.should == 4
          end
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
                           :rss_feed_id => @feed.id
          )
        end

        it "should ignore them" do
          NewsItem.should_receive(:create!).twice
          @feed.freshen
        end
      end

      context "when an exception is raised somewhere along the way" do
        before do
          DateTime.stub!(:parse).and_raise Exception.new("Error Message!")
        end

        it "should log it and move on" do
          Rails.logger.should_receive(:warn).once.with(an_instance_of(Exception))
          @feed.freshen
          @feed.last_crawl_status.should == "Error Message!"
        end
      end
    end

    context "when the feed is in the Atom format" do
      before do
        @feed = rss_feeds(:atom_feed)
        doc = Nokogiri::XML(open(Rails.root.to_s + '/spec/fixtures/rss/atom_feed.xml'))
        Nokogiri::XML::Document.should_receive(:parse).and_return(doc)
      end

      context "when there are no news items associated with the source" do
        before do
          @feed.news_items.delete_all
        end

        it "should populate news items from the RSS feed source with HTML stripped from the description" do
          @feed.freshen
          @feed.reload
          @feed.news_items.count.should == 25
          newest = @feed.news_items.first
          newest.guid.should == "http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/22642"
          newest.link.should == "http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/22642"
          newest.published_at.should == DateTime.parse("2009-11-30T12:00:00-05:00")
          newest.description[0, 40].should == "Assessing Consistency and Fairness in Se"
          newest.title.should == "Assessing Consistency and Fairness in Sentencing in Michigan, Minnesota, and Virginia, 2001-2002, 2004"
        end
      end
    end

    context "when the RSS feed format can not be determined" do
      before do
        @feed = rss_feeds(:atom_feed)
        @feed.news_items.destroy_all
        @feed.stub!(:detect_feed_type).and_return nil
      end

      it "should not change the number of news items, and update the crawl status" do
        @feed.freshen
        @feed.reload
        @feed.news_items.count.should == 0
        @feed.last_crawl_status.should == "Unkown feed type."
      end
    end
  end

  describe "#is_video?" do
    let(:affiliate) { affiliates(:power_affiliate) }

    context "when url starts with http://gdata.youtube.com/feeds/base/videos?alt=rss&author=" do
      specify { affiliate.rss_feeds.create!(:name => 'Videos', :url => 'http://GDATA.youtube.com/feeds/base/videos?AUTHOR=noaa').should be_is_video }
    end

    context "when url does not start with http://gdata.youtube.com/feeds/" do
      specify { affiliate.rss_feeds.create!(:name => 'Not videos', :url => 'http://www.rss.noaa.gov/noaarss.xml').should_not be_is_video }
    end
  end

  describe ".navigable_only" do
    let(:affiliate) { affiliates(:power_affiliate) }
    let(:navigable_only) { Affiliate.find(affiliate.id).rss_feeds.navigable_only }

    before do
      affiliate.rss_feeds.create!(:name => 'navigable rss feed 1', :url => 'http://searchblog.usa.gov/rss', :is_navigable => true, :position => 3)
      affiliate.rss_feeds.create!(:name => 'navigable rss feed 2', :url => 'http://searchblog.usa.gov/rss', :is_navigable => true, :position => 2)
      affiliate.rss_feeds.create!(:name => 'navigable rss feed 3', :url => 'http://searchblog.usa.gov/rss', :is_navigable => true, :position => 1)
      affiliate.rss_feeds.create!(:name => 'not navigable rss feed', :url => 'http://searchblog.usa.gov/rss', :is_navigable => false, :position => 0)
    end

    specify { navigable_only.count.should == 3 }
    specify { navigable_only.collect(&:is_navigable).uniq.should == [true] }
    specify { navigable_only.collect(&:position).should == [1, 2, 3] }
  end

  describe ".govbox_enabled" do
    let(:affiliate) { affiliates(:power_affiliate) }
    let(:govbox_enabled) { Affiliate.find(affiliate.id).rss_feeds.govbox_enabled }

    before do
      affiliate.rss_feeds.create!(:name => 'govbox rss feed 1', :url => 'http://searchblog.usa.gov/rss', :shown_in_govbox => true)
      affiliate.rss_feeds.create!(:name => 'not govbox rss feed', :url => 'http://searchblog.usa.gov/rss', :shown_in_govbox => false)
    end

    it "should scope the collection to the govbox enabled RssFeeds" do
      govbox_enabled.count.should == 1
      govbox_enabled.first.name.should == 'govbox rss feed 1'
    end
  end

  describe ".managed" do
    let(:affiliate) { affiliates(:power_affiliate) }
    let(:managed) { Affiliate.find(affiliate.id).rss_feeds.managed }

    before do
      affiliate.rss_feeds.create!(:name => 'not managed', :url => 'http://searchblog.usa.gov/rss')
      affiliate.rss_feeds.create!(:name => 'managed', :url => 'http://searchblog.usa.gov/rss', :is_managed => true)
    end

    specify { managed.count.should == 1 }
    specify { managed.first.name.should == 'managed' }
  end

  describe ".videos" do
    let(:affiliate) { affiliates(:power_affiliate) }
    let(:videos) { Affiliate.find(affiliate.id).rss_feeds.videos }

    before do
      affiliate.rss_feeds.create!(:name => 'Not vidoes', :url => 'http://searchblog.usa.gov/rss')
      affiliate.rss_feeds.create!(:name => 'Videos', :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&user=USGovernment')
    end

    specify { videos.count.should == 1 }
    specify { videos.first.name.should == 'Videos' }
  end
end