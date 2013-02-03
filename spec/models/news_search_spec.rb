require 'spec_helper'

describe NewsSearch do
  fixtures :affiliates, :rss_feeds, :navigations, :news_items

  let(:affiliate) { affiliates(:basic_affiliate) }

  before(:all) do
    NewsItem.reindex
  end

  describe "#initialize(options)" do
    let(:feed) { affiliate.rss_feeds.first }

    it "should set the time-based search parameter" do
      search = NewsSearch.new(:query => '   element   OR', :tbs => "w", :affiliate => affiliate)
      search.since.should == Time.current.advance(weeks: -1).beginning_of_day
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
        NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate).rss_feed.should == feed
      end
    end

    context "when another affiliate's RSS feed is specified" do
      it "should set the rss_feed member to nil" do
        another_feed = rss_feeds(:another)
        NewsSearch.new(:query => 'element', :channel => another_feed.id, :affiliate => affiliate).rss_feed.should be_nil
      end
    end

    context 'when channel is not a valid number' do
      it 'should set the rss_feed member to nil' do
        NewsSearch.new(query: 'element', channel: { 'foo' => 'bar' }, affiliate: affiliate).rss_feed.should be_nil
      end
    end

    context "when the query param isn't set" do
      it "should set 'query' to a blank string" do
        NewsSearch.new(:channel => feed.id, :affiliate => affiliate).query.should be_blank
      end
    end

    context 'when the since_date param is valid' do
      it 'should set since to a parsed Date' do
        news_search = NewsSearch.new(channel: feed.id, affiliate: affiliate, since_date: '10/1/2012')
        news_search.since.to_s.should == '2012-10-01 00:00:00 UTC'
        news_search.until.should be_nil
      end
    end

    context 'when until_date is not present and the since_date param is not valid' do
      it 'should set since to a year ago' do
        news_search = NewsSearch.new(channel: feed.id, affiliate: affiliate, since_date: '13/41/2012')
        news_search.since.should == Time.current.advance(years: -1).beginning_of_day
        news_search.until.should be_nil
      end
    end

    context 'when until_date is present and the since_date param is not valid' do
      it 'should set since to a year ago before until_date' do
        news_search = NewsSearch.new(channel: feed.id, affiliate: affiliate, since_date: '13/41/2012', until_date: '10/15/2012')
        news_search.since.to_s == '2011-10-15 00:00:00 UTC'
        news_search.until.to_s == '2012-10-15 23:59:59 UTC'
      end
    end

    context 'when the until_date param is valid' do
      it 'should set until to the end of day of that date' do
        news_search = NewsSearch.new(channel: feed.id, affiliate: affiliate, until_date: '10/31/2012')
        news_search.since.should be_nil
        news_search.until.to_s.should == '2012-10-31 23:59:59 UTC'
      end
    end

    context 'when the until_date param is not valid' do
      it 'should set until to the end of day' do
        news_search = NewsSearch.new(channel: feed.id, affiliate: affiliate, until_date: '13/41/2012')
        news_search.since.should be_nil
        news_search.until.should == Time.current.end_of_day
      end
    end

    context 'when since_date is greater than until_date' do
      it 'should swap since and until' do
        news_search = NewsSearch.new(channel: feed.id, affiliate: affiliate, since_date: '10/31/2012', until_date: '9/1/2012')
        news_search.since.to_s.should == '2012-09-01 00:00:00 UTC'
        news_search.until.to_s.should == '2012-10-31 23:59:59 UTC'
      end
    end

    context 'when locale is set to :es' do
      before(:all) { I18n.locale = :es }

      context 'when the since_date param is valid' do
        it 'should use Spanish date format' do
          news_search = NewsSearch.new(channel: feed.id, affiliate: affiliate, since_date: '1/10/2012')
          news_search.since.to_s.should == '2012-10-01 00:00:00 UTC'
        end
      end

      context 'when the end_date param is valid' do
        it 'should use Spanish date format' do
          news_search = NewsSearch.new(channel: feed.id, affiliate: affiliate, until_date: '1/10/2012')
          news_search.until.to_s.should == '2012-10-01 23:59:59 UTC'
        end
      end

      after(:all) { I18n.locale = I18n.default_locale }
    end
  end

  describe "#run" do
    it "should log info about the query and module impressions" do
      SaytSuggestion.stub!(:related_search).and_return %{some array}
      search = NewsSearch.new(:query => 'element', :affiliate => affiliate)
      QueryImpression.should_receive(:log).with(:news, affiliate.name, 'element', ['NEWS', 'SREL'])
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
        @search.module_tag.should be_nil
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
        search = NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate, :contributor => 'contributor', :publisher => 'publisher', :subject => 'subject')
        NewsItem.should_receive(:search_for).with('element', [feed], { since: nil, until: nil }, 1, 10, 'contributor', 'subject', 'publisher', false)
        search.run.should be_true
      end
    end

    context "when a valid video RSS feed is specified" do
      let(:feed) { affiliate.rss_feeds.create!(:name => 'Video', :rss_feed_urls_attributes => { '0' => { :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse' } }) }

      it "should set per_page to 21" do
        search = NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate)
        NewsItem.should_receive(:search_for).with('element', [feed], { since: nil, until: nil }, 1, 21, nil, nil, nil, false)
        search.run.should be_true
      end
    end

    context "when no RSS feed is specified" do
      it "should search for news items from all active feeds for the affiliate" do
        one_week_ago = Time.current.advance(weeks: -1).beginning_of_day
        search = NewsSearch.new(:query => 'element', :tbs => "w", :affiliate => affiliate)
        NewsItem.should_receive(:search_for).with('element', affiliate.rss_feeds.navigable_only, { since: one_week_ago, until: nil }, 1, 10, nil, nil, nil, false)
        search.run
      end
    end

    context 'when searching with since_date' do
      it 'should search for NewsItem with since option' do
        feed = mock_model(RssFeed, is_video?: false)
        affiliate.stub_chain(:rss_feeds, :find_by_id).with(feed.id).and_return(feed)

        news_search = NewsSearch.new(query: 'element', channel: feed.id, affiliate: affiliate, since_date: '10/1/2012')
        NewsItem.should_receive(:search_for).with('element', [feed], { since: Time.parse('2012-10-01 00:00:00Z'), until: nil }, 1, 10, nil, nil, nil, false)

        news_search.run
      end
    end

    context 'when searching with until_date' do
      it 'should search for NewsItem with until option' do
        feed = mock_model(RssFeed, is_video?: false)
        affiliate.stub_chain(:rss_feeds, :find_by_id).with(feed.id).and_return(feed)
        until_ts = Time.parse('2012-10-31')
        Time.should_receive(:strptime).with('10/31/2012', '%m/%d/%Y').and_return(until_ts.clone)
        news_search = NewsSearch.new(query: 'element', channel: feed.id, affiliate: affiliate, until_date: '10/31/2012')
        NewsItem.should_receive(:search_for).with('element', [feed], { since: nil, until: until_ts.utc.end_of_day }, 1, 10, nil, nil, nil, false)

        news_search.run
      end
    end

    context 'when sorting by relevance' do
      it 'should pass in the sort_by param' do
        feed = affiliate.rss_feeds.first
        search = NewsSearch.new(:query => 'element', :channel => feed.id, :affiliate => affiliate, :contributor => 'contributor', :publisher => 'publisher', :subject => 'subject', :sort_by => 'r')
        NewsItem.should_receive(:search_for).with('element', [feed], { since: nil, until: nil }, 1, 10, 'contributor', 'subject', 'publisher', true)
        search.run.should be_true
      end
    end
  end

  describe "#cache_key" do
    let(:options) { { query: 'element', affiliate: affiliate} }
    let(:feed) { affiliate.rss_feeds.create!(:name => 'Video', :rss_feed_urls_attributes => { '0' => { :url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse' } }) }
    let(:since_a_week_ago) { Date.current.advance(weeks: -1).to_s }

    it "should output a key based on the affiliate id, query, channel, tbs, since-until, page, and per_page parameters" do
      NewsSearch.new(options.merge(tbs: 'w', channel: feed.id, page: 2)).cache_key.should == "#{affiliate.id}:element:#{feed.id}:#{since_a_week_ago}:2:21"
      NewsSearch.new(options.merge(channel: feed.id)).cache_key.should == "#{affiliate.id}:element:#{feed.id}::1:21"
      NewsSearch.new(options.merge(tbs: 'w')).cache_key.should == "#{affiliate.id}:element::#{since_a_week_ago}:1:10"
      NewsSearch.new(options.merge(since_date: '10/1/2012', until_date: '10/31/2012')).cache_key.should == "#{affiliate.id}:element::2012-10-01..2012-10-31:1:10"
    end
  end

end
