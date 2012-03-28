require 'spec/spec_helper'

describe AffiliateObserver do
  describe "#after_create" do
    context "when youtube handle is specified" do
      it "should create a managed 'Videos' RSS feed" do
        affiliate = Affiliate.new(:display_name => 'site with videos', :youtube_handle => 'USGovernment')
        rss_feeds = mock('rss feeds')
        affiliate.should_receive(:rss_feeds).and_return(rss_feeds)
        rss_feeds.should_receive(:create!).with(hash_including(:name => 'Videos', :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usgovernment&orderby=published', :is_managed => true))
        affiliate.save!
      end
    end

    context "when youtube handle is blank" do
      it "should not create RSS Feed" do
        affiliate = Affiliate.new(:display_name => 'site with videos', :youtube_handle => '')
        affiliate.should_not_receive(:rss_feeds)
        affiliate.save!
      end
    end
  end

  describe "#after_update" do
    context "when there is an existing managed video RSS feed" do
      let(:affiliate) { Affiliate.create!(:display_name => 'site with videos', :youtube_handle => 'USGovernment') }
      let(:managed_video_feeds) { affiliate.rss_feeds.managed.videos }

      context "when youtube handle is specified" do
        before { affiliate.update_attributes!(:youtube_handle => 'USAgov') }

        it "should have 1 managed video rss feed" do
          managed_video_feeds.count.should == 1
        end

        it "should have a Videos RSS feed with youtube URL" do
          managed_video_feeds.first.name.should == 'Videos'
          managed_video_feeds.first.url.should == 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usagov&orderby=published'
          managed_video_feeds.first.should be_is_managed
        end
      end

      context "when youtube handle is different from the old handle" do
        it "should delete old news_items" do
          managed_video_rss_feed = mock('managed video rss feed', :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usgovernment&orderby=published')
          news_items = mock('news items')
          managed_video_rss_feed.should_receive(:news_items).and_return(news_items)
          news_items.should_receive(:destroy_all)
          managed_video_rss_feed.should_receive(:update_attributes!).with(
              hash_including(:url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usagov&orderby=published',
                             :last_crawled_at => nil,
                             :last_crawl_status => nil))

          affiliate.stub_chain(:rss_feeds, :managed, :videos, :first) { managed_video_rss_feed }
          affiliate.update_attributes!(:youtube_handle => 'USAgov')
        end
      end

      context "when the youtube handle does not change" do
        it "should not update managed video rss_feed" do
          managed_video_rss_feed = mock('managed video rss feed', :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usgovernment&orderby=published')
          managed_video_rss_feed.should_not_receive(:news_items)
          managed_video_rss_feed.should_not_receive(:update_attributes!)

          affiliate.stub_chain(:rss_feeds, :managed, :videos, :first) { managed_video_rss_feed }
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

        it "should have 1 managed video rss feed" do
          managed_video_feeds.count.should == 1
        end

        it "should have a Videos RSS feed with youtube URL" do
          managed_video_feeds.first.name.should == 'Videos'
          managed_video_feeds.first.url.should == 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usagov&orderby=published'
          managed_video_feeds.first.should be_is_managed
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
