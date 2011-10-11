require 'spec/spec_helper'

describe NewsSearch do
  fixtures :affiliates, :rss_feeds, :news_items, :calais_related_searches

  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    NewsItem.reindex
    CalaisRelatedSearch.reindex
  end

  describe "#initialize(affiliate, options)" do
    let(:search) { NewsSearch.new(affiliate, {"query" => '   element   OR', "tbs" => "w"}) }

    it "should set the time-based search parameter" do
      (search.since - 1.week.ago).should be_within(0.5).of(0)
    end

    it "should downcase a query ending in OR" do
      search.query.should == "element or"
    end

    it "should strip extra whitespace" do
      search.query.should == "element or"
    end

    context "when the tbs param isn't set" do
      it "should set 'since' to nil" do
        NewsSearch.new(affiliate, {"query" => 'element'}).since.should be_nil
      end
    end

    context "when the tbs param isn't valid" do
      it "should set 'since' to nil" do
        NewsSearch.new(affiliate, {"query" => 'element', "tbs" => "invalid"}).since.should be_nil
      end
    end

    context "when a valid and active RSS feed is specified" do
      it "should set the rss_feed member" do
        feed = affiliate.rss_feeds.first
        NewsSearch.new(affiliate, {"query" => 'element', "channel" => feed.id}).rss_feed.should == feed
      end
    end

    context "when an inactive RSS feed is specified" do
      it "should set the rss_feed member to nil" do
        feed = affiliate.rss_feeds.first
        feed.update_attribute(:is_active, false)
        NewsSearch.new(affiliate, {"query" => 'element', "channel" => feed.id}).rss_feed.should be_nil
      end
    end

    context "when another affiliate's RSS feed is specified" do
      it "should set the rss_feed member to nil" do
        feed = rss_feeds(:another)
        NewsSearch.new(affiliate, {"query" => 'element', "channel" => feed.id}).rss_feed.should be_nil
      end
    end

    context "when the query param isn't set" do
      it "should set 'query' to a blank string" do
        NewsSearch.new(affiliate,"channel" => affiliate.rss_feeds.first.id).query.should be_blank
      end
    end

  end

  describe "#run" do
    it "should log info about the query and module impressions" do
      search = NewsSearch.new(affiliate, {"query" => 'element'})
      QueryImpression.should_receive(:log).with(:news, affiliate.name, 'element', ["NEWS", 'CREL'])
      search.run
    end

    context "when searching with really long queries" do
      before do
        @search = NewsSearch.new(affiliate, {"query" => "X" * (Search::MAX_QUERYTERM_LENGTH + 1)})
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
        @search = NewsSearch.new(affiliate, {"query" => "   "})
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
        search = NewsSearch.new(affiliate, {"query" => 'element', "channel" => feed.id})
        NewsItem.should_receive(:search_for).with('element', [feed], nil, 1)
        search.run.should be_true
      end
    end

    context "when an invalid/inactive RSS feed is specified" do
      it "should search for news items from all active feeds for the affiliate" do
        feed = affiliate.rss_feeds.first
        feed.update_attribute(:is_active, false)
        search = NewsSearch.new(affiliate, {"query" => 'element', "channel" => feed.id, "page" => 2})
        NewsItem.should_receive(:search_for).with('element', affiliate.active_rss_feeds, nil, 2)
        search.run
      end
    end

    context "when no RSS feed is specified" do
      it "should search for news items from all active feeds for the affiliate" do
        search = NewsSearch.new(affiliate, {"query" => 'element', "tbs" => "w"})
        NewsItem.should_receive(:search_for).with('element', affiliate.active_rss_feeds, an_instance_of(ActiveSupport::TimeWithZone), 1)
        search.run
      end
    end

  end
end
