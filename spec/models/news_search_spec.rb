require 'spec/spec_helper'

describe NewsSearch do
  fixtures :affiliates, :rss_feeds, :news_items

  let(:affiliate) { affiliates(:basic_affiliate) }

  before(:all) do
    NewsItem.reindex
  end

  describe "#initialize(options)" do
    let(:search) { NewsSearch.new(:query => '   element   OR', :tbs => "w", :affiliate => affiliate) }

    before do
      search.class.name.should == 'NewsSearch'
    end

    it "should set the time-based search parameter" do
      (search.since - 1.week.ago).should be_within(0.5).of(0)
    end

    context "when the tbs param isn't set" do
      it "should set 'since' to nil" do
        NewsSearch.new(:query => 'element', :affiliate => affiliate).since.should be_nil
      end
    end

    context "when the tbs param isn't valid" do
      it "should set 'since' to nil" do
        NewsSearch.new(:query => 'element', :tbs => "invalid", :affiliate => affiliate).since.should be_nil
      end
    end

    context "when a valid RSS feed is specified" do
      it "should set the rss_feed member" do
        feed = affiliate.rss_feeds.first
        NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate).rss_feed.should == feed
      end
    end

    context "when another affiliate's RSS feed is specified" do
      it "should set the rss_feed member to nil" do
        feed = rss_feeds(:another)
        NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate).rss_feed.should be_nil
      end
    end

    context "when the query param isn't set" do
      it "should set 'query' to a blank string" do
        NewsSearch.new(:channel => affiliate.rss_feeds.first.id, :affiliate => affiliate).query.should be_blank
      end
    end
  end

  describe "#run" do
    it "should log info about the query and module impressions" do
      SaytSuggestion.stub!(:related_search).and_return %{some array}
      search = NewsSearch.new(:query => 'element', :affiliate => affiliate)
      QueryImpression.should_receive(:log).with(:news, affiliate.name, 'element', ["NEWS", 'SREL'])
      search.run
    end

    context "when searching with really long queries" do
      before do
        @search = NewsSearch.new(:query => "X" * (Search::MAX_QUERYTERM_LENGTH + 1), :affiliate => affiliate)
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should == 0
        @search.hits.size.should == 0
        @search.total.should == 0
      end

      it "should set error message" do
        @search.run
        @search.error_message.should_not be_nil
      end
    end

    context "when searching with a blank query" do
      before do
        @search = NewsSearch.new(:query => "   ", :affiliate => affiliate)
      end

      it "should return true when searching" do
        @search.run.should be_true
      end

      it "should have more than 0 results" do
        @search.run
        @search.results.size.should > 0
      end

      it "should not set error message" do
        @search.run
        @search.error_message.should be_nil
      end
    end

    context "when a valid active RSS feed is specified" do
      it "should only search for news items from that feed" do
        feed = affiliate.rss_feeds.first
        search = NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate)
        NewsItem.should_receive(:search_for).with('element', [feed], nil, 1, 10)
        search.run.should be_true
      end
    end

    context "when a valid video RSS feed is specified" do
      let(:feed) { affiliate.rss_feeds.create!(:name => 'Video', :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse') }

      it "should set per_page to 20" do
        NewsItem.should_receive(:search_for).with('element', [feed], nil, 1, 20)
        search = NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate)
        search.run.should be_true
      end
    end

    context "when no RSS feed is specified" do
      it "should search for news items from all active feeds for the affiliate" do
        search = NewsSearch.new(:query => 'element', :tbs => "w", :affiliate => affiliate)
        NewsItem.should_receive(:search_for).with('element', affiliate.rss_feeds.navigable_only, an_instance_of(ActiveSupport::TimeWithZone), 1, 10)
        search.run
      end
    end
  end

  describe "#cache_key" do
    let(:feed) { affiliate.rss_feeds.create!(:name => 'Video', :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse') }

    it "should output a key based on the affiliate id, query, channel, tbs, page, and per_page parameters" do
      NewsSearch.new(:query => 'element', :tbs => "w", :affiliate => affiliate, :channel => feed.id, :page => 2).cache_key.should == "#{affiliate.id}:element:#{feed.id}:w:2:20"
      NewsSearch.new(:query => 'element', :affiliate => affiliate, :channel => feed.id).cache_key.should == "#{affiliate.id}:element:#{feed.id}::1:20"
      NewsSearch.new(:query => 'element', :tbs => "w", :affiliate => affiliate).cache_key.should == "#{affiliate.id}:element::w:1:10"
    end
  end

end
