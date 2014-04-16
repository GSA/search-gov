require 'spec_helper'

describe ElasticNewsItem do
  fixtures :affiliates, :rss_feed_urls, :rss_feeds
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:blog) { rss_feeds(:white_house_blog) }
  let(:gallery) { rss_feeds(:white_house_press_gallery) }
  let(:white_house_blog_url) { rss_feed_urls(:white_house_blog_url) }
  let(:white_house_press_gallery_url) { rss_feed_urls(:white_house_press_gallery_url) }

  before do
    ElasticNewsItem.recreate_index
    NewsItem.delete_all
    @blog_item = NewsItem.create!(
      rss_feed_url_id: white_house_blog_url.id,
      guid: 'unique to feed',
      published_at: 3.days.ago,
      link: 'http://www.wh.gov/ns1',
      title: 'Obama adopts policies similar to other policies',
      description: "<p> Ed note: This&nbsp;has been cross-posted&nbsp;from the Office of Science and Technology policy&#39;s <a href='http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime'><img alt='ignore' src='/foo.jpg' />blog</a></p> <p> Today is a good day for policy science and technology, a good day for scientists and engineers, and a good day for the nation and policies.</p>",
      contributor: 'President',
      publisher: 'Briefing Room',
      subject: 'Economy')

    properties = {
      media_thumbnail: {
        url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_s.jpg',
        height: '75', width: '75' },
      media_content: {
        url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_b.jpg',
        type: 'image/jpeg',
        height: '819', width: '1024' }
    }

    @gallery_item = NewsItem.create!(
      rss_feed_url: white_house_press_gallery_url,
      guid: 'unique to feed',
      published_at: 1.day.ago,
      link: 'http://www.wh.gov/ns2',
      title: 'Obama adopts some more things',
      description: '<p>that is the policy.</p>',
      contributor: 'President',
      publisher: 'Briefing Room',
      subject: 'HIV',
      properties: properties)

    ElasticNewsItem.commit
  end

  describe ".search_for" do
    describe "results structure" do
      context 'when there are results' do

        it 'should return results in an easy to access structure' do
          search = ElasticNewsItem.search_for(q: 'Obama', rss_feeds: [blog, gallery], size: 1, offset: 1, language: 'en')
          search.total.should == 2
          search.results.size.should == 1
          search.results.first.should be_instance_of(NewsItem)
          search.offset.should == 1
          search.aggregations.size.should == 3
          contributor_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'contributor' }
          contributor_aggregation.rows.first.value.should == 'President'
          publisher_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'publisher' }
          publisher_aggregation.rows.first.value.should == 'Briefing Room'
          subject_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'subject' }
          subject_aggregation.rows.collect(&:value).should match_array(%w(Economy HIV))
        end

        context 'when those results get deleted' do
          before do
            NewsItem.destroy_all
            ElasticNewsItem.commit
          end

          it 'should return zero results' do
            search = ElasticNewsItem.search_for(q: 'Obama', rss_feeds: [blog, gallery], size: 1, offset: 1, language: 'en')
            search.total.should be_zero
            search.results.size.should be_zero
          end
        end

        context 'when no RSS feed URLs are specified' do
          before do
            RssFeedUrl.delete_all
          end

          it 'should return zero results' do
            search = ElasticNewsItem.search_for(q: 'Obama', rss_feeds: [blog, gallery], size: 1, offset: 1, language: 'en')
            search.total.should be_zero
            search.results.size.should be_zero
          end
        end

        context 'when no RSS feeds are specified' do
          it 'should return zero results' do
            search = ElasticNewsItem.search_for(q: 'Obama', size: 1, offset: 1, language: 'en')
            search.total.should be_zero
            search.results.size.should be_zero
          end
        end
      end

    end

    describe "filters" do

      context 'when RSS feeds are specified' do
        it "should restrict results to the RSS feed URLS belonging to the specified collection of RSS feeds" do
          search = ElasticNewsItem.search_for(q: 'policy', rss_feeds: [blog], language: 'en')
          search.total.should == 1
          search.results.first.should == @blog_item
        end

        context 'when no other filters (e.g., query) are specified' do
          it "should return with all items" do
            ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en').total.should == 2
          end
        end
      end

      context "when excluded URLs are present" do
        before do
          affiliate.excluded_urls.create!(url: "http://www.wh.gov/ns1")
        end

        it 'should filter out NewsItems with those URLs' do
          search = ElasticNewsItem.search_for(q: 'policy', rss_feeds: [blog, gallery], language: 'en', excluded_urls: affiliate.excluded_urls)
          search.total.should == 1
          search.results.first.should == @gallery_item
        end
      end

      context 'when date restrictions are present' do
        it 'should filter out NewsItems outside that date range' do
          search = ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en', since: 2.days.ago)
          search.total.should == 1
          search = ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en', until: 2.days.ago)
          search.total.should == 1
          search = ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en', since: 20.days.ago, until: Time.now)
          search.total.should == 2
          search = ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en', since: 20.days.ago, until: 12.days.ago)
          search.total.should == 0
        end
      end

      context 'when tags are present' do
        it 'should only return news items with those tags' do
          search = ElasticNewsItem.search_for(q: 'policy', rss_feeds: [blog, gallery], language: 'en', tags: %w(image))
          search.total.should == 1
        end
      end

      context "when DublinCore fields are passed in" do
        before do
          NewsItem.create!(rss_feed_url_id: white_house_blog_url.id, guid: 'third', published_at: 3.days.ago, link: 'http://www.wh.gov/ns3',
                           title: 'Policy 3', description: "Random posting", contributor: 'First Lady', publisher: 'Other Folks', subject: 'Space')
          NewsItem.create!(rss_feed_url_id: white_house_blog_url.id, guid: '4', published_at: 3.days.ago, link: 'http://www.wh.gov/ns4',
                           title: 'Policy 4', description: "Random posting", contributor: 'President', publisher: 'Other Folks', subject: 'Space')
          NewsItem.create!(rss_feed_url_id: white_house_blog_url.id, guid: '5', published_at: 3.days.ago, link: 'http://www.wh.gov/ns5',
                           title: 'Policy 5', description: "Random posting", contributor: 'First Lady', publisher: 'Briefing Room', subject: 'Space')
          NewsItem.create!(rss_feed_url_id: white_house_blog_url.id, guid: '6', published_at: 3.days.ago, link: 'http://www.wh.gov/ns6',
                           title: 'Policy 6', description: "Random posting", contributor: 'First Lady', publisher: 'Other Folks', subject: 'Economy')
          NewsItem.create!(rss_feed_url_id: white_house_blog_url.id, guid: '7', published_at: 3.days.ago, link: 'http://www.wh.gov/ns7',
                           title: 'Policy 7', description: "Random posting")
          ElasticNewsItem.commit
        end

        it "should aggregate and restrict results based on those criteria" do
          search = ElasticNewsItem.search_for(contributor: 'President', subject: 'Economy', publisher: 'Briefing Room', rss_feeds: [blog], language: 'en')
          search.total.should == 1
          search.results.first.should == @blog_item
          search.aggregations.size.should == 3
          contributor_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'contributor' }
          contributor_aggregation.rows.collect(&:value).should match_array(["First Lady", "President"])
          publisher_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'publisher' }
          publisher_aggregation.rows.collect(&:value).should match_array(["Other Folks", "Briefing Room"])
          subject_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'subject' }
          subject_aggregation.rows.collect(&:value).should match_array(%w(Economy Space))
        end

        context 'when a field has multiple values (comma separated)' do
          before do
            NewsItem.create!(rss_feed_url_id: white_house_blog_url.id, guid: 'multiple', published_at: 3.days.ago, link: 'http://www.wh.gov/multiple',
                             title: 'Policy Multiple', description: "Random posting with multiple values",
                             contributor: 'First Lady, Contributor', publisher: 'Other Folks, Publisher', subject: 'Space,Subject')
            ElasticNewsItem.commit
          end

          it "should aggregate across multiple values based on those criteria" do
            search = ElasticNewsItem.search_for(contributor: 'President', subject: 'Economy', publisher: 'Briefing Room', rss_feeds: [blog], language: 'en')
            search.aggregations.size.should == 3
            contributor_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'contributor' }
            contributor_aggregation.rows.collect(&:value).should match_array(["First Lady", "President", "Contributor"])
            publisher_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'publisher' }
            publisher_aggregation.rows.collect(&:value).should match_array(["Other Folks", "Briefing Room", "Publisher"])
            subject_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'subject' }
            subject_aggregation.rows.collect(&:value).should match_array(%w(Economy Space Subject))
          end

        end
      end
    end

    describe "sorting" do
      it "should show newest first, by default" do
        search = ElasticNewsItem.search_for(q: "policy", rss_feeds: [blog, gallery], language: 'en')
        search.total.should == 2
        search.results.first.should == @gallery_item
      end

      context "when sort_by_relevance param is true" do
        it 'should sort results by relevance' do
          search = ElasticNewsItem.search_for(q: "policy", rss_feeds: [blog, gallery], language: 'en', sort_by_relevance: true)
          search.results.first.should == @blog_item
        end
      end

      context "when sort_by_relevance param is false" do
        it 'should sort results by date' do
          search = ElasticNewsItem.search_for(q: "policy", rss_feeds: [blog, gallery], language: 'en', sort_by_relevance: false)
          search.results.first.should == @gallery_item
        end
      end
    end

  end

end