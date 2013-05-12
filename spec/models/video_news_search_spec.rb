require 'spec_helper'

describe VideoNewsSearch do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :news_items

  let(:affiliate) { affiliates(:basic_affiliate) }

  describe "#initialize(options)" do
    it "should set the class name to 'VideoNewsSearch'" do
      VideoNewsSearch.new(:query => '   element   OR', :tbs => "w", :affiliate => affiliate).class.name.should == 'VideoNewsSearch'
    end

    it 'should initialize per_page' do
      VideoNewsSearch.new(query: 'gov', tbs: 'w', affiliate: affiliate).per_page.should == 20
    end

    it 'should not overwrite per_page option' do
      VideoNewsSearch.new(query: 'gov', tbs: 'w', affiliate: affiliate, per_page: '15').per_page.should == 15
    end
  end

  describe "#run" do
    context 'when video news items are found' do
      before do
        NewsItem.create!(:link => 'http://www.uspto.gov/web/patents/patog/week12/OG/patentee/alphaB_Utility.htm',
                         :title => "video NewsItem title element",
                         :description => "video NewsItem description element",
                         :published_at => DateTime.parse("2011-09-26 21:33:05"),
                         :guid => '80798 at www.whitehouse.gov',
                         :rss_feed_id => rss_feeds(:managed_video).id,
                         :rss_feed_url_id => rss_feed_urls(:youtube_video).id)
        NewsItem.reindex
        Sunspot.commit
      end

      it "should log info about the query and module impressions" do
        search = VideoNewsSearch.new(:query => 'element', :affiliate => affiliate, :channel => rss_feeds(:managed_video).id)
        QueryImpression.should_receive(:log).with(:news, affiliate.name, 'element', ['VIDS'])
        search.run
      end
    end

    context "when a valid active RSS feed is specified" do
      it "should only search for news items from that feed" do
        rss_feed = mock_model(RssFeed, is_video?: true)
        affiliate.stub_chain(:rss_feeds, :videos, :find_by_id).and_return(rss_feed)
        search = VideoNewsSearch.new(query: 'element', channel: '100', affiliate: affiliate)
        NewsItem.should_receive(:search_for).with('element', [rss_feed], { since: nil, until: nil }, 1, 20, nil, nil, nil, false)
        search.run.should be_true
      end
    end

    context "when no RSS feed is specified" do
      it "should search for news items from all navigable video feeds for the affiliate" do
        videos_navigable_feeds = mock('videos navigable only rss feeds', { :count => 2 })
        affiliate.stub_chain(:rss_feeds, :videos, :navigable_only).and_return(videos_navigable_feeds)
        time_range = { since: Time.current.advance(weeks: -1).beginning_of_day, until: nil }
        NewsItem.should_receive(:search_for).with('element', videos_navigable_feeds, time_range, 1, 20, nil, nil, nil, false)
        search = VideoNewsSearch.new(query: 'element', tbs: 'w', affiliate: affiliate)
        search.run
      end
    end

    context "when there is only 1 navigable video rss feed" do
      it "should assign @rss_feed" do
        rss_feed = mock_model(RssFeed, is_video?: true)
        affiliate.stub_chain(:rss_feeds, :videos, :navigable_only).and_return([rss_feed])
        time_range = { since: Time.current.advance(weeks: -1).beginning_of_day, until: nil }
        NewsItem.should_receive(:search_for).with('element', [rss_feed], time_range, 1, 20, nil, nil, nil, false)
        search = VideoNewsSearch.new(query: 'element', tbs: 'w', affiliate: affiliate)
        search.run
        search.rss_feed.should == rss_feed
      end
    end
  end
end