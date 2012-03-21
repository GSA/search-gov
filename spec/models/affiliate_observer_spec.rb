require 'spec/spec_helper'

describe AffiliateObserver do
  describe "#after_create" do
    context "when youtube handle is specified" do
      it "should create a managed 'Videos' RSS feed" do
        affiliate = Affiliate.new(:display_name => 'site with videos', :youtube_handle => 'USGovernment')
        rss_feeds = mock('rss feeds')
        affiliate.should_receive(:rss_feeds).and_return(rss_feeds)
        rss_feeds.should_receive(:create!).with(hash_including(:name => 'Videos', :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usgovernment', :is_managed => true))
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

        specify { managed_video_feeds.count.should == 1 }
        specify { managed_video_feeds.first.name.should == 'Videos' }
        specify { managed_video_feeds.first.url.should == 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usagov' }
        specify { managed_video_feeds.first.should be_is_managed }
      end

      context "when youtube handle is not specified" do
        before { affiliate.update_attributes!(:youtube_handle => '') }

        specify { managed_video_feeds.count.should == 0 }
      end
    end

    context "when there is no existing managed video RSS feed" do
      let(:affiliate) { Affiliate.create!(:display_name => 'site with videos') }
      let(:managed_video_feeds) { affiliate.rss_feeds.managed.videos }

      context "when youtube handle is specified" do
        before { affiliate.update_attributes!(:youtube_handle => 'USAgov') }

        specify { managed_video_feeds.count.should == 1 }
        specify { managed_video_feeds.first.name.should == 'Videos' }
        specify { managed_video_feeds.first.url.should == 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=usagov' }
        specify { managed_video_feeds.first.should be_is_managed }
      end

      context "when youtube handle is not specified" do
        before { affiliate.update_attributes!(:youtube_handle => '') }

        specify { managed_video_feeds.count.should == 0 }
      end
    end
  end
end
