require 'spec/spec_helper'

describe NewsSearch do
  fixtures :affiliates, :rss_feeds, :news_items

  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    NewsItem.reindex
  end

  describe "#initialize(options)" do
    let(:search) { NewsSearch.new(:query => '   element   OR', :tbs => "h", :affiliate => affiliate) }

    before do
      search.class.name.should == 'NewsSearch'
    end

    context "when the tbs param is set" do
      it "should set the time-based search parameter within an hour of the tbs target" do
        (1.hour.ago - search.since).should < 3600
      end

      it "should set the minute and second to 0 to aid Solr in caching by the hour" do
        search.since.min.should be_zero
        search.since.sec.should be_zero
      end
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

      it "should return false when searching" do
        @search.run.should be_false
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should == 0
      end

      it "should set error message" do
        @search.run
        @search.error_message.should_not be_nil
      end
    end

    context "when a valid active RSS feed is specified" do
      it "should only search for news items from that feed" do
        feed = affiliate.rss_feeds.first
        search = NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate)
        NewsItem.should_receive(:search_for).with('element', [feed], nil, 1, [])
        search.run.should be_true
      end
    end

    context "when no RSS feed is specified" do
      it "should search for news items from all active feeds for the affiliate" do
        search = NewsSearch.new(:query => 'element', :tbs => "w", :affiliate => affiliate)
        NewsItem.should_receive(:search_for).with('element', affiliate.rss_feeds.navigable_only, an_instance_of(ActiveSupport::TimeWithZone), 1, [])
        search.run
      end
    end
  end
end
