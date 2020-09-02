require 'spec_helper'

describe ElasticNewsItem do
  fixtures :affiliates, :rss_feed_urls, :rss_feeds
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:blog) { rss_feeds(:white_house_blog) }
  let(:gallery) { rss_feeds(:white_house_press_gallery) }
  let(:white_house_blog_url) { rss_feed_urls(:white_house_blog_url) }
  let(:white_house_press_gallery_url) { rss_feed_urls(:white_house_press_gallery_url) }
  let(:search_params) do
    {
      q: 'Obama',
      rss_feeds: [blog]
    }
  end
  let(:search) { ElasticNewsItem.search_for(search_params) }

  before do
    ElasticNewsItem.recreate_index
    NewsItem.delete_all
    @blog_item = NewsItem.create!(
      rss_feed_url_id: white_house_blog_url.id,
      guid: 'unique to feed',
      published_at: 3.days.ago,
      link: 'http://www.wh.gov/ns1',
      title: 'Obama adopts policies similar to other policies',
      description: "<p> Ed note: This&nbsp;has been cross-posted&nbsp;from the Office of Science and Technology policy&#39;s <a href='http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime'><img alt='ignore' src='/foo.jpg' />blog</a></p> <p> Today is a good day for policy science and technology, a good day for scientists and petrol, and a good day for the nation and policies.</p>",
      body: 'random text here',
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
      title: 'Obama adopts some more things about some other things',
      description: '<p>that is the policy.</p><p>This is a paragraph full of other,
                   less relevant words. These are more random words to ensure that
                   the relevance calculation is comparing document fields
                   of similar lengths.<\p>',
      contributor: 'President',
      publisher: 'Briefing Room',
      subject: 'HIV',
      properties: properties)

    ElasticNewsItem.commit
  end

  describe '.search_for' do
    describe 'results structure' do
      context 'when there are results' do

        it 'should return results in an easy to access structure' do
          search = ElasticNewsItem.search_for(q: 'Obama', rss_feeds: [blog, gallery], size: 1, offset: 1, language: 'en')
          expect(search.total).to eq(2)
          expect(search.results.size).to eq(1)
          expect(search.results.first).to be_instance_of(NewsItem)
          expect(search.offset).to eq(1)
          expect(search.aggregations.size).to eq(3)
          contributor_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'contributor' }
          expect(contributor_aggregation.rows.first.value).to eq('President')
          publisher_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'publisher' }
          expect(publisher_aggregation.rows.first.value).to eq('Briefing Room')
          subject_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'subject' }
          expect(subject_aggregation.rows.collect(&:value)).to match_array(%w(Economy HIV))
        end

        context 'when those results get deleted' do
          before do
            NewsItem.destroy_all
            ElasticNewsItem.commit
          end

          it 'should return zero results' do
            search = ElasticNewsItem.search_for(q: 'Obama', rss_feeds: [blog, gallery], size: 1, offset: 1, language: 'en')
            expect(search.total).to be_zero
            expect(search.results.size).to be_zero
          end
        end

        context 'when no RSS feed URLs are specified' do
          before do
            RssFeedUrl.delete_all
          end

          it 'should return zero results' do
            search = ElasticNewsItem.search_for(q: 'Obama', rss_feeds: [blog, gallery], size: 1, offset: 1, language: 'en')
            expect(search.total).to be_zero
            expect(search.results.size).to be_zero
          end
        end

        context 'when no RSS feeds are specified' do
          it 'should return zero results' do
            search = ElasticNewsItem.search_for(q: 'Obama', size: 1, offset: 1, language: 'en')
            expect(search.total).to be_zero
            expect(search.results.size).to be_zero
          end
        end
      end

    end

    describe 'filters' do
      context 'when RSS feeds are specified' do
        it "should restrict results to the RSS feed URLS belonging to the specified collection of RSS feeds" do
          search = ElasticNewsItem.search_for(q: 'policy', rss_feeds: [blog], language: 'en')
          expect(search.total).to eq(1)
          expect(search.results.first).to eq(@blog_item)
        end

        context 'when no other filters (e.g., query) are specified' do
          it "should return with all items" do
            expect(ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en').total).to eq(2)
          end
        end
      end

      context "when excluded URLs are present" do
        before do
          affiliate.excluded_urls.create!(url: "http://www.wh.gov/ns1")
        end

        it 'should filter out NewsItems with those URLs' do
          search = ElasticNewsItem.search_for(q: 'policy', rss_feeds: [blog, gallery], language: 'en', excluded_urls: affiliate.excluded_urls)
          expect(search.total).to eq(1)
          expect(search.results.first).to eq(@gallery_item)
        end
      end

      context 'when date restrictions are present' do
        it 'should filter out NewsItems outside that date range' do
          search = ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en', since: 2.days.ago)
          expect(search.total).to eq(1)
          search = ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en', until: 2.days.ago)
          expect(search.total).to eq(1)
          search = ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en', since: 20.days.ago, until: Time.now)
          expect(search.total).to eq(2)
          search = ElasticNewsItem.search_for(rss_feeds: [blog, gallery], language: 'en', since: 20.days.ago, until: 12.days.ago)
          expect(search.total).to eq(0)
        end
      end

      context 'when tags are present' do
        it 'should only return news items with those tags' do
          search = ElasticNewsItem.search_for(q: 'policy', rss_feeds: [blog, gallery], language: 'en', tags: %w(image))
          expect(search.total).to eq(1)
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
          expect(search.total).to eq(1)
          expect(search.results.first).to eq(@blog_item)
          expect(search.aggregations.size).to eq(3)
          contributor_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'contributor' }
          expect(contributor_aggregation.rows.collect(&:value)).to match_array(["First Lady", "President"])
          publisher_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'publisher' }
          expect(publisher_aggregation.rows.collect(&:value)).to match_array(["Other Folks", "Briefing Room"])
          subject_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'subject' }
          expect(subject_aggregation.rows.collect(&:value)).to match_array(%w(Economy Space))
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
            expect(search.aggregations.size).to eq(3)
            contributor_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'contributor' }
            expect(contributor_aggregation.rows.collect(&:value)).to match_array(["First Lady", "President", "Contributor"])
            publisher_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'publisher' }
            expect(publisher_aggregation.rows.collect(&:value)).to match_array(["Other Folks", "Briefing Room", "Publisher"])
            subject_aggregation = search.aggregations.detect { |aggregation| aggregation.name == 'subject' }
            expect(subject_aggregation.rows.collect(&:value)).to match_array(%w(Economy Space Subject))
          end

        end
      end

      context 'when searching only on titles' do
        it 'should not match on text in description or body fields' do
          expect(ElasticNewsItem.search_for(q: 'petrol', rss_feeds: [blog, gallery], language: 'en', title_only: true).total).to be_zero
          expect(ElasticNewsItem.search_for(q: 'random', rss_feeds: [blog, gallery], language: 'en', title_only: true).total).to be_zero
        end
      end

      context 'when indexing news items in other languages' do
        let(:search_params) do
          {
            rss_feeds: [blog],
            language: affiliate.indexing_locale,
            title_only: true,
            q: 'superknuller'
          }
        end
        let(:news_item_params) do
          {
            rss_feed_url_id: white_house_blog_url.id,
            guid: 'greenland',
            published_at: 3.days.ago,
            link: 'http://www.wh.gov/greenland',
            title: 'Angebote und Superknüller der Woche',
            description: "desc",
            body: 'random text here',
            contributor: 'President',
            publisher: 'Briefing Room',
            subject: 'Economy'
          }
        end

        context 'when affiliate locale is not one of the custom indexed languages' do
          before do
            affiliate.update!(locale: 'kl')
            NewsItem.create!(news_item_params)
            ElasticNewsItem.commit
          end

          it 'does downcasing and ASCII folding only' do
            expect(search.total).to eq(1)
            expect(search.results.first.title).to match(/Angebote/)
          end
        end

        context 'when the rss feed url is not one of the custom indexed languages' do
          before do
            white_house_blog_url.update!(language: 'kl')
            affiliate.update!(locale: 'kl')
            NewsItem.create!(news_item_params)
            ElasticNewsItem.commit
          end

          it 'does downcasing and ASCII folding only' do
            expect(search.total).to eq(1)
            expect(search.results.first.title).to match(/Angebote/)
          end
        end
      end
    end

    describe "sorting" do
      it "should show newest first, by default" do
        search = ElasticNewsItem.search_for(q: "policy", rss_feeds: [blog, gallery], language: 'en')
        expect(search.total).to eq(2)
        expect(search.results.first).to eq(@gallery_item)
      end

      context "when sort_by_relevance param is true" do
        it 'should sort results by relevance' do
          search = ElasticNewsItem.search_for(q: "policy", rss_feeds: [blog, gallery], language: 'en', sort: '_score')
          expect(search.results.first).to eq(@blog_item)
        end
      end

      context "when sort_by_relevance param is false" do
        it 'should sort results by date' do
          search = ElasticNewsItem.search_for(q: "policy", rss_feeds: [blog, gallery], language: 'en', sort: 'published_at:desc')
          expect(search.results.first).to eq(@gallery_item)
        end
      end
    end

    context 'synonyms and protected words' do
      it "should use both" do
        search = ElasticNewsItem.search_for(q: "gas", rss_feeds: [blog, gallery], language: 'en')
        expect(search.total).to eq(1)
        expect(search.results.first).to eq(@blog_item)
      end
    end

  end

end
