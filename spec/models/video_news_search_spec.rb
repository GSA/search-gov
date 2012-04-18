require 'spec/spec_helper'

describe VideoNewsSearch do
  fixtures :affiliates, :rss_feeds, :news_items

  let(:affiliate) { affiliates(:basic_affiliate) }

  before(:all) do
    NewsItem.reindex
  end

  describe "#initialize(options)" do
    it "should set the class name to 'VideoNewsSearch'" do
      VideoNewsSearch.new(:query => '   element   OR', :tbs => "w", :affiliate => affiliate).class.name.should == 'VideoNewsSearch'
    end
  end

  describe "#run" do
    context "when a valid active RSS feed is specified" do
      it "should only search for news items from that feed" do
        rss_feed = mock_model(RssFeed)
        affiliate.stub_chain(:rss_feeds, :videos, :find_by_id).and_return(rss_feed)
        rss_feed.stub!(:is_video?).and_return true
        search = VideoNewsSearch.new(:query => 'element', :channel => '100', :affiliate => affiliate)
        NewsItem.should_receive(:search_for).with('element', [rss_feed], nil, 1)
        search.run.should be_true
      end
    end

    context "when no RSS feed is specified" do
      it "should search for news items from all navigable video feeds for the affiliate" do
        search = VideoNewsSearch.new(:query => 'element', :tbs => "w", :affiliate => affiliate)
        videos_navigable_feeds = mock('videos navigable only rss feeds', { :count => 0 })
        affiliate.stub_chain(:rss_feeds, :videos, :navigable_only).and_return(videos_navigable_feeds)
        NewsItem.should_receive(:search_for).with('element', videos_navigable_feeds, an_instance_of(ActiveSupport::TimeWithZone), 1)
        search.run
      end
    end

    context "when there is only 1 navigable video rss feed" do
      it "should assign @rss_feed" do
        search = VideoNewsSearch.new(:query => 'element', :tbs => "w", :affiliate => affiliate)
        videos_navigable_feeds = mock('videos navigable only rss feeds', { :count => 1 })
        rss_feed = mock_model(RssFeed)
        videos_navigable_feeds.should_receive(:first).and_return(rss_feed)
        affiliate.stub_chain(:rss_feeds, :videos, :navigable_only).and_return(videos_navigable_feeds)
        NewsItem.should_receive(:search_for).with('element', videos_navigable_feeds, an_instance_of(ActiveSupport::TimeWithZone), 1)
        search.run
        search.rss_feed.should == rss_feed
      end
    end
  end
end
