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
  it { should have_many(:news_items) }
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
      rss_feed.should_not_receive(:synchronize_youtube_urls!)
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

        blog_xml = File.read(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        Kernel.should_receive(:open).exactly(2).times do
          blog_xml
        end
      end

      it "should retrieve videos from non playlist urls first" do
        rss_feed.freshen
        rss_feed.rss_feed_urls.find_by_url('http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse').news_items.should_not be_empty
        rss_feed.rss_feed_urls.find_by_url('http://gdata.youtube.com/feeds/api/playlists/FAKEID1').news_items.should be_empty
      end
    end

    context 'when the feed is managed' do
      let(:managed_feed) { rss_feeds(:managed_video) }

      it 'should synchronize youtube urls' do
        managed_feed.should_receive(:synchronize_youtube_urls!)
        youtube_url = mock_model(RssFeedUrl, :is_playlist? => false)
        playlist_url = mock_model(RssFeedUrl, :is_playlist? => true)
        managed_feed.should_receive(:rss_feed_urls).with(true).and_return([youtube_url])
        managed_feed.should_receive(:rss_feed_urls).with(no_args).and_return([playlist_url])
        youtube_url.should_receive(:freshen)
        playlist_url.should_receive(:freshen)
        managed_feed.freshen
      end
    end
  end

  describe "#synchronize_youtube_urls!" do
    let(:affiliate) { Affiliate.create!(:display_name => 'site with youtube profile') }
    let(:managed_feed) do
      feed = RssFeed.new(:affiliate => affiliate, :name => 'Videos')
      feed.is_managed = true

      %w(old1 old2 nochange).each do |username|
        feed.rss_feed_urls.build(:url => YoutubeProfile.youtube_url(username))
        url = "http://gdata.youtube.com/feeds/api/playlists/#{username}?start-index=1&max-results=50"
        feed.rss_feed_urls.build(:url => url)
      end

      feed.save(:validate => false)
      RssFeed.find(feed.id)
    end

    context 'when affiliate has youtube_profiles' do
      let(:new_owned_video_urls) do
        %w(new1 new2 nochange).collect do |username|
          YoutubeProfile.youtube_url(username)
        end
      end

      let(:new_playlist_video_urls) do
        %w(new1 new2 nochange).collect do |playlist_id|
          "http://gdata.youtube.com/feeds/api/playlists/#{playlist_id}?start-index=1&max-results=50"
        end
      end

      before do
        youtube_xml = File.read(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        Kernel.stub(:open) do |arg|
          case arg
          when %r[^http://gdata.youtube.com/feeds/base/videos\?]
            youtube_xml
          when %r[^http://gdata.youtube.com/feeds/api/playlists/*]
            youtube_xml
          end
        end

        youtube_profiles = new_owned_video_urls.collect do |url|
          mock_model(YoutubeProfile, :url => url)
        end
        managed_feed.affiliate.should_receive(:youtube_profiles).
            and_return(youtube_profiles)

        managed_feed.should_receive(:query_youtube_playlist_urls).
            and_return(new_playlist_video_urls)
      end

      it 'should synchronize youtube urls' do
        no_change_rss_feed_url_ids = RssFeedUrl.where('rss_feed_id = ? AND url like ?', managed_feed.id, '%nochange%').collect(&:id)
        managed_feed.synchronize_youtube_urls!
        managed_feed.rss_feed_urls(true).reject(&:is_playlist?).collect(&:url).should == new_owned_video_urls
        managed_feed.rss_feed_urls(true).select(&:is_playlist?).collect(&:url).should == new_playlist_video_urls
        managed_feed.rss_feed_urls.collect(&:id).sort.should include(*no_change_rss_feed_url_ids.sort)
        managed_feed.should_not be_destroyed
      end
    end

    context 'when affiliate does not have youtube profile' do
      before do
        managed_feed.affiliate.should_receive(:youtube_profiles).and_return([])
        managed_feed.should_receive(:query_youtube_playlist_urls).and_return([])
      end

      it 'should destroy self' do
        managed_feed.synchronize_youtube_urls!
        managed_feed.rss_feed_urls(true).should be_blank
        managed_feed.should be_destroyed
      end
    end
  end

  describe "#query_youtube_playlist_urls" do
    let(:affiliate) { Affiliate.create!(:display_name => 'site with youtube playlists') }
    let(:first_youtube_url) { YoutubeProfile.youtube_url('whitehouse') }
    let(:youtube_xml) { File.read(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml') }
    let(:playlist_xml) { File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_playlists.xml') }

    let(:managed_feed) do
      feed = RssFeed.new(:affiliate => affiliate, :name => 'Videos')
      feed.is_managed = true
      feed.rss_feed_urls.build(:url => first_youtube_url)
      feed.save(:validate => false)

      RssFeed.find(feed.id)
    end

    before do
      managed_feed.affiliate.should_receive(:youtube_profiles).
          and_return([mock_model(YoutubeProfile, :username => 'whitehouse')])
    end

    it 'should generate playlist urls' do
      Kernel.stub(:open) do |arg|
        case arg
        when 'http://gdata.youtube.com/feeds/api/users/whitehouse/playlists?start-index=1&max-results=50&v=2'
          playlist_xml
        end
      end

      urls = managed_feed.query_youtube_playlist_urls
      urls.count.should == 45
      urls.first.should == 'http://gdata.youtube.com/feeds/api/playlists/0064C709336510C9?alt=rss&start-index=1&max-results=50&v=2'
      urls.last.should == 'http://gdata.youtube.com/feeds/api/playlists/E94EF18328AC72F3?alt=rss&start-index=1&max-results=50&v=2'
    end

    context 'when the totalResults is 0' do
      let(:blank_playlist_xml) { File.read(Rails.root.to_s + '/spec/fixtures/rss/no_entry_playlist.xml') }

      before do
        Kernel.stub(:open) do |arg|
          case arg
          when 'http://gdata.youtube.com/feeds/api/users/whitehouse/playlists?start-index=1&max-results=50&v=2'
            blank_playlist_xml
          end
        end
      end

      it 'should not raise an Exception' do
        Rails.logger.should_not_receive(:warn)
        urls = managed_feed.query_youtube_playlist_urls
        urls.count.should == 0
      end
    end

    context 'when totalResults > 50' do
      before do
        playlist_xml = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_playlists_with_next_url.xml')
        next_playlist_xml = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_next_playlists.xml')
        Kernel.stub(:open) do |arg|
          case arg
          when 'http://gdata.youtube.com/feeds/api/users/whitehouse/playlists?start-index=1&max-results=50&v=2'
            playlist_xml
          when 'http://gdata.youtube.com/feeds/api/users/whitehouse/playlists?start-index=51&max-results=50&v=2'
            next_playlist_xml
          end
        end
      end

      it "should retrieve all playlist urls" do
        urls = managed_feed.query_youtube_playlist_urls
        urls.count.should == 52
        urls.first.should == 'http://gdata.youtube.com/feeds/api/playlists/0064C709336510C9?alt=rss&start-index=1&max-results=50&v=2'
        urls.last.should == 'http://gdata.youtube.com/feeds/api/playlists/FAKEID52?alt=rss&start-index=1&max-results=50&v=2'
      end
    end

    context "when Kernel.open raises an exception" do
      let(:first_youtube_url) { YoutubeProfile.youtube_url('whitehouse') }
      let(:youtube_xml) { File.read(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml') }

      before do
        managed_feed.rss_feed_urls.destroy_all
        %w(FAKEID1 FAKEID2).each do |playlist_id|
          url = "http://gdata.youtube.com/feeds/api/playlists/#{playlist_id}?alt=rss&start-index=1&max-results=50&v=2"
          rss_feed_url = managed_feed.rss_feed_urls.build(:url => url)
          rss_feed_url.save(:validate => false)
        end
      end

      it "should return current YouTube playlist urls" do
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
