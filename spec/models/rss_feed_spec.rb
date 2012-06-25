require 'spec/spec_helper'

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
  it { should have_many(:news_items) }
  it { should_not allow_mass_assignment_of(:is_managed) }
  it { should_not allow_mass_assignment_of(:is_video) }


  context "on create" do
    before do
      rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
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
    context "when ignore_managed_feeds is true" do
      it "should freshen non managed rss_feeds" do
        blog = rss_feeds(:white_house_blog)
        gallery = rss_feeds(:white_house_press_gallery)
        RssFeed.should_receive(:all).with(:conditions => { :is_managed => false},
                                          :order => 'affiliate_id ASC, id ASC').and_return([blog, gallery])
        blog.should_receive(:freshen)
        gallery.should_receive(:freshen)
        RssFeed.refresh_all
      end
    end

    context "when ignore_managed_feeds is false" do
      it "should freshen managed rss_feeds" do
        managed = mock_model(RssFeed)
        RssFeed.should_receive(:all).with(:conditions => { :is_managed => true},
                                          :order => 'affiliate_id ASC, id ASC').and_return([managed])
        managed.should_receive(:freshen)
        RssFeed.refresh_all(true)
      end
    end
  end

  describe "#freshen" do
    let(:rss_feed) { rss_feeds(:white_house_blog) }

    it "should freshen all RssFeedUrl" do
      blog_feed_url = mock_model(RssFeedUrl, :is_playlist? => false)
      news_feed_url = mock_model(RssFeedUrl, :is_playlist? => false)
      rss_feed.should_receive(:rss_feed_urls).with(true).and_return([blog_feed_url, news_feed_url])
      rss_feed.should_receive(:rss_feed_urls).with(no_args).and_return([])
      blog_feed_url.should_receive(:freshen)
      news_feed_url.should_receive(:freshen)
      rss_feed.freshen
    end

    context "when playlist contains duplicate news items" do
      before do
        rss_feed.rss_feed_urls.destroy_all
        non_playlist_url = rss_feed.rss_feed_urls.build(:url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse')
        non_playlist_url.save(:validate => false)
        playlist_url = rss_feed.rss_feed_urls.build(:url => 'http://gdata.youtube.com/feeds/api/playlists/FAKEID1')
        playlist_url.save(:validate => false)

        blog_xml = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        Kernel.should_receive(:open).exactly(2).times do
          blog_xml.rewind
          blog_xml
        end
      end

      it "should retrieve videos from non playlist urls first" do
        rss_feed.freshen
        rss_feed.rss_feed_urls.find_by_url('http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse').news_items.should_not be_empty
        rss_feed.rss_feed_urls.find_by_url('http://gdata.youtube.com/feeds/api/playlists/FAKEID1').news_items.should be_empty
      end
    end
  end

  describe "#synchronize_youtube_playlists" do
    let(:affiliate) { Affiliate.create!(:display_name => 'site with youtube playlists') }
    let(:managed_feed) { affiliate.rss_feeds(true).managed.first }
    let(:youtube_playlist_urls) { %w(http://gdata.youtube.com/feeds/api/playlists/FAKEID1?start-index=1&max-results=50
                                     http://gdata.youtube.com/feeds/api/playlists/FAKEID2?start-index=1&max-results=50
                                     http://gdata.youtube.com/feeds/api/playlists/FAKEID3?start-index=1&max-results=50) }
    before do
      affiliate.youtube_profiles.create!(:username => 'whitehouse')
    end

    it "should add new youtube playlists" do
      managed_feed.should_receive(:query_youtube_playlist_urls).and_return(youtube_playlist_urls.clone)
      Kernel.should_receive(:open).exactly(3).times do
        File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_playlists.xml')
      end
      managed_feed.synchronize_youtube_playlists
      managed_feed.rss_feed_urls(true).count.should == 4
      managed_feed.rss_feed_urls.select(&:is_playlist?).collect(&:url).should == youtube_playlist_urls
    end

    context "when there is an obsolete youtube playlist url" do
      before do
        first_obsolete_url = managed_feed.rss_feed_urls.build(:url => 'http://gdata.youtube.com/feeds/api/playlists/OBSOLETE1?start-index=1&max-results=50')
        first_obsolete_url.save(:validate => false)
        second_obsolete_url = managed_feed.rss_feed_urls.build(:url => 'http://gdata.youtube.com/feeds/api/playlists/FAKEID2?start-index=1&max-results=50')
        second_obsolete_url.save(:validate => false)
      end

      it "should remove the obsolete youtube playlist url" do
        managed_feed.rss_feed_urls(true).count.should == 3
        managed_feed.should_receive(:query_youtube_playlist_urls).and_return(youtube_playlist_urls.clone)
        Kernel.should_receive(:open).exactly(2).times do
          File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_playlists.xml')
        end
        managed_feed.synchronize_youtube_playlists
        managed_feed.rss_feed_urls(true).count.should == 4
        managed_feed.rss_feed_urls.select(&:is_playlist?).collect(&:url).sort.should == youtube_playlist_urls
      end
    end
  end

  describe "#query_youtube_playlist_urls" do
    let(:affiliate) { Affiliate.create!(:display_name => 'site with youtube playlists') }
    before { affiliate.youtube_profiles.create(:username => 'whitehouse') }

    it "should generate playlist urls" do
      managed_feed = affiliate.rss_feeds(true).managed.first
      playlists_xml = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_playlists.xml')
      Kernel.should_receive(:open).with('http://gdata.youtube.com/feeds/api/users/whitehouse/playlists?start-index=1&max-results=50&v=2').and_return(playlists_xml)
      urls = managed_feed.query_youtube_playlist_urls
      urls.count.should == 45
      urls.first.should == 'http://gdata.youtube.com/feeds/api/playlists/0064C709336510C9?alt=rss&start-index=1&max-results=50&v=2'
      urls.last.should == 'http://gdata.youtube.com/feeds/api/playlists/E94EF18328AC72F3?alt=rss&start-index=1&max-results=50&v=2'
    end

    context "when totalResults > 50" do
      it "should retrieve all playlist urls" do
        managed_feed = affiliate.rss_feeds(true).managed.first
        playlists_xml = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_playlists_with_next_url.xml')
        Kernel.should_receive(:open).with('http://gdata.youtube.com/feeds/api/users/whitehouse/playlists?start-index=1&max-results=50&v=2').and_return(playlists_xml)
        next_playlists_xml = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_next_playlists.xml')
        Kernel.should_receive(:open).with('http://gdata.youtube.com/feeds/api/users/whitehouse/playlists?start-index=51&max-results=50&v=2').and_return(next_playlists_xml)
        urls = managed_feed.query_youtube_playlist_urls
        urls.count.should == 52
        urls.first.should == 'http://gdata.youtube.com/feeds/api/playlists/0064C709336510C9?alt=rss&start-index=1&max-results=50&v=2'
        urls.last.should == 'http://gdata.youtube.com/feeds/api/playlists/FAKEID52?alt=rss&start-index=1&max-results=50&v=2'
      end
    end

    context "when Kernel.open raises an exception" do
      let(:managed_feed) { affiliate.rss_feeds(true).managed.first }

      before do
        first_url = managed_feed.rss_feed_urls.build(:url => 'http://gdata.youtube.com/feeds/api/playlists/FAKEID1?alt=rss&start-index=1&max-results=50&v=2')
        first_url.save(:validate => false)
        second_url = managed_feed.rss_feed_urls.build(:url => 'http://gdata.youtube.com/feeds/api/playlists/FAKEID2?alt=rss&start-index=1&max-results=50&v=2')
        second_url.save(:validate => false)
      end

      it "should return current YouTube playlist urls" do
        managed_feed = affiliate.rss_feeds(true).managed.first
        Kernel.should_receive(:open).and_raise
        urls = managed_feed.query_youtube_playlist_urls
        urls.count.should == 2
        urls.first.should == 'http://gdata.youtube.com/feeds/api/playlists/FAKEID1?alt=rss&start-index=1&max-results=50&v=2'
        urls.second.should == 'http://gdata.youtube.com/feeds/api/playlists/FAKEID2?alt=rss&start-index=1&max-results=50&v=2'
      end
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

      before do
        video_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        Kernel.stub(:open) { video_content.rewind; video_content }
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
