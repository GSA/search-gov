require 'spec/spec_helper'

describe RssFeed do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls
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
  it { should have_many(:news_items) }
  it { should_not allow_mass_assignment_of(:is_managed) }
  it { should_not allow_mass_assignment_of(:is_video) }


  context "on create" do
    it "should create a new instance given valid attributes" do
      RssFeed.create!(@valid_attributes)
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

  context "on save" do
    it "should not save when all RssFeedUrl are marked for destruction" do
      blog = rss_feeds(:white_house_blog)
      rss_feed_url = blog.rss_feed_urls.first
      blog.update_attributes(:rss_feed_urls_attributes => { '0' => { :id => rss_feed_url.id,
                                                                     :url => rss_feed_url.url,
                                                                     :_destroy => '1'} }).should be_false
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
    let(:blog_feed_url) { mock_model(RssFeedUrl) }
    let(:news_feed_url) { mock_model(RssFeedUrl) }
    let(:rss_feed) { rss_feeds(:white_house_blog) }

    it "should freshen all RssFeedUrl" do
      rss_feed.should_receive(:rss_feed_urls).and_return([blog_feed_url, news_feed_url])
      blog_feed_url.should_receive(:freshen)
      news_feed_url.should_receive(:freshen)
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

      specify { rss_feed.should be_is_video }
    end

    context "when at least one RssFeedUrl is not video" do
      let(:rss_feed) do
        affiliate.rss_feeds.create!(:name => 'Not only videos',
                                    :rss_feed_urls_attributes => { '0' => { :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=USGovernment' },
                                                                   '1' => { :url => 'http://usasearch.howto.gov/rss' } })
      end

      specify { rss_feed.should_not be_is_video }
    end
  end

  describe ".navigable_only" do
    let(:affiliate) { affiliates(:power_affiliate) }
    let(:rss_feed_urls_attributes) { { '0' => { :url => 'http://usasearch.howto.gov/rss' } } }

    let!(:navigable_feeds) do
      navigable_feeds = []
      navigable_feeds << affiliate.rss_feeds.create!(:name => 'navigable rss feed 1',
                                                     :is_navigable => true,
                                                     :position => 10,
                                                     :rss_feed_urls_attributes => rss_feed_urls_attributes)
      navigable_feeds << affiliate.rss_feeds.create!(:name => 'navigable rss feed 2',
                                                     :is_navigable => true,
                                                     :position => 5,
                                                     :rss_feed_urls_attributes => rss_feed_urls_attributes)
      navigable_feeds << affiliate.rss_feeds.create!(:name => 'navigable rss feed 3',
                                                     :is_navigable => true,
                                                     :position => 1,
                                                     :rss_feed_urls_attributes => rss_feed_urls_attributes)
      navigable_feeds
    end

    it "includes rss feeds with is_navigable flag" do
      affiliate.rss_feeds.navigable_only.should include(*navigable_feeds)
    end

    it "sorts rss feeds with is_navigable flag by position" do
      affiliate.rss_feeds.navigable_only.collect(&:position).should == [1,5,10]
    end

    it "excludes rss feeds with is_navigable flag" do
      not_navigable_feed = affiliate.rss_feeds.create!(:name => 'not navigable rss feed',
                                                       :is_navigable => false,
                                                       :position => 0,
                                                       :rss_feed_urls_attributes => rss_feed_urls_attributes)
      affiliate.rss_feeds.navigable_only.should_not include(not_navigable_feed)
    end
  end

  describe ".govbox_enabled" do
    let(:affiliate) { affiliates(:power_affiliate) }

    it "includes rss feeds with shown_in_govbox flag" do
      govbox_enabled = affiliate.rss_feeds.create!(:name => 'govbox rss feed 1',
                                                   :shown_in_govbox => true,
                                                   :rss_feed_urls_attributes => { '0' => { :url => 'http://usasearch.howto.gov/rss' } })
      affiliate.rss_feeds.govbox_enabled.should include(govbox_enabled)
    end

    it "excludes rss feeds without shown_in_govbox flag" do
      not_govbox_enabled = affiliate.rss_feeds.create!(:name => 'not govbox rss feed',
                                                       :shown_in_govbox => false,
                                                       :rss_feed_urls_attributes => { '0' => { :url => 'http://usasearch.howto.gov/rss' } })
      affiliate.rss_feeds.govbox_enabled.should_not include(not_govbox_enabled)
    end
  end

  describe ".managed" do
    let(:affiliate) { affiliates(:power_affiliate) }

    it "includes rss feeds with is_managed flag" do
      managed_feed = affiliate.rss_feeds.build(:name => 'Managed',
                                               :rss_feed_urls_attributes => { '0' => { :url => 'http://usasearch.howto.gov/rss' } })
      managed_feed.is_managed = true
      managed_feed.save!
      managed_feed
      affiliate.rss_feeds.managed.should include(managed_feed)
    end

    it "excludes rss feeds without is_managed flag" do
      not_managed_feed = affiliate.rss_feeds.create!(:name => 'Not managed',
                                                     :rss_feed_urls_attributes => { '0' => { :url => 'http://usasearch.howto.gov/rss' } })
      affiliate.rss_feeds.managed.should_not include(not_managed_feed)
    end
  end

  describe ".videos" do
    let(:affiliate) { affiliates(:power_affiliate) }

    it "includes rss feeds with is_video flag" do
      video_feed = affiliate.rss_feeds.create!(:name => 'Videos',
                                               :rss_feed_urls_attributes => { '0' => { :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&user=USGovernment' } })
      affiliate.rss_feeds.videos.should include(video_feed)
    end

    it "excludes rss feeds without is_video flag" do
      not_video_feed = affiliate.rss_feeds.create!(:name => 'Not videos',
                                                   :rss_feed_urls_attributes => { '0' => { :url => 'http://usasearch.howto.gov/rss' } })
      affiliate.rss_feeds.videos.should_not include(not_video_feed)
    end
  end

  describe ".non_videos" do
    let(:affiliate) { affiliates(:power_affiliate) }

    it "includes rss feeds without is_video flag" do
      not_video_feed = affiliate.rss_feeds.create!(:name => 'Not videos',
                                                   :rss_feed_urls_attributes => { '0' => { :url => 'http://usasearch.howto.gov/rss' } })
      affiliate.rss_feeds.non_videos.should include(not_video_feed)
    end

    it "excludes rss feeds with is_video flag" do
      video_feed = affiliate.rss_feeds.create!(:name => 'Videos',
                                  :rss_feed_urls_attributes => { '0' => { :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&user=USGovernment' } })
      affiliate.rss_feeds.non_videos.should_not include(video_feed)
    end
  end
end
