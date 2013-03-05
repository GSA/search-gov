require 'spec_helper'

describe RssFeedUrl do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls

  it { should belong_to :rss_feed }
  it { should have_many(:news_items).dependent(:destroy) }
  it { should validate_presence_of :url }

  describe "validation" do
    let(:rss_feed) { rss_feeds(:basic) }

    context "when the RSS feed is a valid feed" do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
        HttpConnection.should_receive(:get).with('http://bogus.example.gov/feed/blog').and_return(rss_feed_content)
      end

      it "should be_valid" do
        expect { rss_feed.rss_feed_urls.create!(:url => 'http://bogus.example.gov/feed/blog') }.to_not raise_error
      end
    end

    context "when the URL does not point to an RSS feed" do
      before do
        not_rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/html/usa_gov/site_index.html')
        HttpConnection.should_receive(:get).with('http://bogus.example.gov/not_feed/blog').and_return(not_rss_feed_content)
      end

      it "should not be valid" do
        rss_feed_url = rss_feed.rss_feed_urls.build(:url => 'http://bogus.example.gov/not_feed/blog')
        rss_feed_url.should_not be_valid
        rss_feed_url.errors.full_messages.should include('Url does not appear to be a valid RSS feed.')
      end
    end

    context "when some error is raised in checking the RSS feed" do
      before do
        HttpConnection.should_receive(:get).and_raise('Some exception')
      end

      it "should not be valid" do
        rss_feed_url = rss_feed.rss_feed_urls.build(:url => 'http://bogus.example.gov/feed/with_error')
        rss_feed_url.should_not be_valid
        rss_feed_url.errors.full_messages.should include('Url does not appear to be a valid RSS feed. Additional information: Some exception')
      end
    end

    context "when URL has the wrong format" do
      it "should not be valid" do
        rss_feed_url = rss_feed.rss_feed_urls.build(:url => 'not_a_valid_url')
        rss_feed_url.save.should be_false
        rss_feed_url.errors[:url].should include('is invalid')
      end
    end

    context "when URL has not changed" do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
        HttpConnection.should_receive(:get).with('http://bogus.example.gov/feed').and_return(rss_feed_content)
      end

      it "should not validate url again" do
        rss_feed_url = rss_feed.rss_feed_urls.create!(:url => 'http://bogus.example.gov/feed')
        rss_feed_url.update_attributes!(:last_crawled_at => Time.current)
      end
    end
  end

  describe "#is_video?" do
    let(:rss_feed) { rss_feeds(:basic) }

    context "when url starts with gdata.youtube.com/feeds/" do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        HttpConnection.should_receive(:get).with('http://gdata.youtube.com/feeds/base/videos?alt=rss&user=USGovernment').and_return(rss_feed_content)
      end

      specify { rss_feed.rss_feed_urls.create!(:url => 'http://gdata.youtube.com/feeds/base/videos?alt=rss&user=USGovernment').should be_is_video }
    end
  end
end
