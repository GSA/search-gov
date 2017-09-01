# coding: utf-8
require 'spec_helper'

describe WebResultsPostProcessor do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls

  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:post_processor) { WebResultsPostProcessor.new('foo', affiliate, results) }

  describe '#post_processed_results' do
    context "when results contain excluded URLs" do
      let(:excluded_url) { "http://www.uspto.gov/web.html" }
      let(:results) do
        results = []
        5.times { |x| results << Hashie::Mash::Rash.new(title: 'title', content: 'content', unescaped_url: "http://foo.gov/#{x}") }
        results << Hashie::Mash::Rash.new(title: 'exclude', content: 'me', unescaped_url: excluded_url)
      end

      let(:processed_results) { post_processor.post_processed_results }

      before do
        ExcludedUrl.create!(:url => excluded_url, :affiliate => affiliate)
      end

      it "should filter out the excluded URLs" do
        processed_results.any? { |result| result['unescapedUrl'] == excluded_url }.should be false
        processed_results.size.should == 5
      end

      context 'when the result url is malformed' do
        #https://www.pivotaltracker.com/n/projects/24228/stories/137463695
        let(:excluded_url) do
          'https://www.dhs.gov/blog/2013/11/15/securing-our-nation%E2%EF%BF%BD%EF%BF%BDs-critical'
        end
        let(:results) do
          [Hashie::Mash::Rash.new(title: 'do not exclude', content: 'me', unescaped_url: excluded_url)]
        end

        it 'does not filter out the url' do
          expect(processed_results).not_to be_empty
        end
      end
    end

    context "when results have an URL that matches a known NewsItem URL" do
      let(:results) do
        results = []
        results << Hashie::Mash::Rash.new(title: 'Title w/o highlighting',
                                    content: 'Description w/o highlighting',
                                    unescaped_url: 'http://www.uspto.gov/web/patents/patog/week23/OG/patentee/alphaC_Utility.htm')
        results << Hashie::Mash::Rash.new(title: 'NewsItem title highlighted from ES',
                                    content: 'NewsItem description highlighted from ES',
                                    unescaped_url: 'http://www.uspto.gov/web/patents/patog/week12/OG/patentee/alphaB_Utility.htm')
      end

      before do
        ElasticNewsItem.recreate_index
        NewsItem.delete_all
        NewsItem.create!(:link => 'http://www.uspto.gov/web/patents/patog/week12/OG/patentee/alphaB_Utility.htm',
                         :title => "NewsItem title highlighted from ElasticSearch",
                         :description => "NewsItem description highlighted from ElasticSearch",
                         :published_at => DateTime.parse("2011-09-26 21:33:05"),
                         :guid => '80798 at www.whitehouse.gov',
                         :rss_feed_url_id => rss_feed_urls(:white_house_blog_url).id)
        NewsItem.create!(:link => 'http://www.uspto.gov/web/patents/patog/week23/OG/patentee/alphaC_Utility.htm',
                         :title => "Title w/o highlighting",
                         :description => "Description w/o highlighting",
                         :published_at => DateTime.parse("2011-09-26 21:33:06"),
                         :guid => '80799 at www.whitehouse.gov',
                         :rss_feed_url_id => rss_feed_urls(:white_house_blog_url).id)
        15.times do |x|
          NewsItem.create!(:link => "http://www.uspto.gov/web/patents/patog/week12/OG/patentee/#{x}.htm",
                           :title => "This is not very relevant but it is recent #{x}",
                           :description => "This description has little information #{x} but manages to mention NewsItem once",
                           :published_at => Time.now,
                           :guid => "#{x} at www.whitehouse.gov",
                           :rss_feed_url_id => rss_feed_urls(:white_house_blog_url).id)
        end
        ElasticNewsItem.commit
        post_processor = WebResultsPostProcessor.new('NewsItem', affiliate, results)
        @post_processed_results = post_processor.post_processed_results
      end

      it "should replace Bing's result title with the NewsItem title" do
        @post_processed_results.first['title'].should == "Title w/o highlighting"
        @post_processed_results.first['content'].should == "Description w/o highlighting"
        @post_processed_results.last['title'].should == "\xEE\x80\x80NewsItem\xEE\x80\x81 title highlighted from ElasticSearch"
        @post_processed_results.last['content'].should == "\xEE\x80\x80NewsItem\xEE\x80\x81 description highlighted from ElasticSearch"
      end

      it 'should assign published date from news item' do
        @post_processed_results.first['publishedAt'].should == DateTime.parse("2011-09-26 21:33:06")
        @post_processed_results.last['publishedAt'].should == DateTime.parse("2011-09-26 21:33:05")
      end
    end
  end
end
