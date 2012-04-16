require 'spec/spec_helper'

describe AffiliateObserver do
  describe "#after_create" do
    context "when youtube handle is specified" do
      it "should create a managed 'Videos' RSS feed" do
        affiliate = Affiliate.new(:display_name => 'site with videos', :youtube_handle => 'USGovernment')
        affiliate.save!
        rss_feeds =  Affiliate.find(affiliate.id).rss_feeds
        rss_feeds.count.should == 1
        rss_feed = rss_feeds.first
        rss_feed.name.should == 'Videos'
        rss_feed.should be_is_managed
        rss_feed.should be_is_video
        rss_feed_urls =  rss_feed.rss_feed_urls
        rss_feed_urls.count.should == 1
        rss_feed_url = rss_feed_urls.first
        rss_feed_url.url.should == 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usgovernment&orderby=published'
      end
    end

    context "when youtube handle is blank" do
      it "should not create RSS Feed" do
        affiliate = Affiliate.new(:display_name => 'site with videos', :youtube_handle => '')
        affiliate.save!
        Affiliate.find(affiliate.id).rss_feeds.should be_blank
      end
    end
  end

  describe "#after_update" do
    context "when there is an existing managed video RSS feed" do
      let(:affiliate) { Affiliate.create!(:display_name => 'site with videos', :youtube_handle => 'USGovernment') }
      let(:managed_video_feeds) { affiliate.rss_feeds.managed.videos }
      let(:video_feed_urls) { managed_video_feeds.first.rss_feed_urls }

      context "when youtube handle is specified" do

        it "should have a Videos RSS feed with youtube URL" do
          affiliate.update_attributes!(:youtube_handle => 'USAgov')

          managed_video_feeds.count.should == 1
          video_feed = managed_video_feeds.first
          video_feed.name.should == 'Videos'

          video_feed_urls.count.should == 1
          video_feed_url = video_feed_urls.first
          video_feed_url.url.should == 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usagov&orderby=published'
        end
      end

      context "when youtube handle is different from the old handle" do
        it "should delete existing rss_feed_url" do
          existing_rss_feed_url = affiliate.rss_feeds.first.rss_feed_urls.first
          affiliate.update_attributes!(:youtube_handle => 'USAgov')
          RssFeedUrl.find_by_id(existing_rss_feed_url.id).should be_blank
        end

        it "should create a new RssFeedUrl" do
          affiliate.update_attributes!(:youtube_handle => 'USAgov')
          video_feed_urls.count.should == 1
          video_feed_url = video_feed_urls.first
          video_feed_url.url.should == 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usagov&orderby=published'
        end
      end

      context "when the youtube handle does not change" do
        it "should not update managed video rss_feed" do
          rss_feed = mock_model(RssFeed)
          affiliate.stub_chain(:rss_feeds, :managed, :videos, :first).and_return(rss_feed)
          rss_feed.should_receive(:blank?).and_return(false)
          rss_feed.stub_chain(:rss_feed_urls, :first, :url).and_return('http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usgovernment&orderby=published')
          affiliate.update_attributes!(:youtube_handle => 'usgovernment')
        end
      end

      context "when youtube handle is not specified" do
        before { affiliate.update_attributes!(:youtube_handle => '') }

        it "should not have managed video rss feed" do
          managed_video_feeds.count.should == 0
        end
      end
    end

    context "when there is no existing managed video RSS feed" do
      let(:affiliate) { Affiliate.create!(:display_name => 'site with videos') }
      let(:managed_video_feeds) { affiliate.rss_feeds.managed.videos }

      context "when youtube handle is specified" do
        before { affiliate.update_attributes!(:youtube_handle => 'USAgov') }

        it "should have a Videos RSS feed with youtube URL" do
          managed_video_feeds.count.should == 1
          managed_video_feeds.first.name.should == 'Videos'
          managed_video_feeds.first.rss_feed_urls.count.should == 1
          managed_video_feeds.first.rss_feed_urls.first.url.should == 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usagov&orderby=published'
        end
      end

      context "when youtube handle is not specified" do
        before { affiliate.update_attributes!(:youtube_handle => '') }

        it "should not have managed video rss feed" do
          managed_video_feeds.count.should == 0
        end
      end
    end
  end
end
