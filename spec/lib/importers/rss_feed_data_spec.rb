require 'spec_helper'

describe RssFeedData do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls

  describe '#import' do
    let(:rss_feed_url) { rss_feed_urls(:basic_url) }
    before { allow(UrlStatusCodeFetcher).to receive(:fetch) { '200 OK' } }

    context 'when the feed is empty' do
      let(:rss_feed_content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/empty.xml').read
      end
      before do
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
        rss_feed_url.news_items.destroy_all
      end

      it 'reflect that feed looks empty in last_crawl_status' do
        RssFeedData.new(rss_feed_url).import
        expect(rss_feed_url.reload.last_crawl_status).to eq 'Feed looks empty'
      end
    end

    context 'when the feed has an item that fails HTTP HEAD validation' do
      let(:rss_feed_content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog_missing_description.xml').read
      end

      before do
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
        allow(UrlStatusCodeFetcher).to receive(:fetch) do |arg|
          status_code =
              case arg
                when 'http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution'
                  '404 Not Found'
                else
                  '200 OK'
              end
          { arg => status_code }
        end
        rss_feed_url.news_items.destroy_all
        RssFeedData.new(rss_feed_url).import
      end

      it 'should populate and index just the news items that are valid' do
        expect(rss_feed_url.news_items.count).to eq(1)
      end

      it 'should reflect that 404 in the feed status' do
        expect(rss_feed_url.last_crawl_status).to eq('Linked URL does not exist (HTTP 404)')
      end
    end

    context 'when the feed has an item that is missing the pubDate field' do
      let(:rss_feed_content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog_missing_pubdate.xml').read
      end

      before do
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
        rss_feed_url.news_items.destroy_all
        RssFeedData.new(rss_feed_url).import
      end

      it 'should populate and index just the news items that are valid' do
        expect(rss_feed_url.news_items.count).to eq(2)
      end

      it 'should reflect the missing pubDate in the last_crawl_status field' do
        expect(rss_feed_url.last_crawl_status).to eq('Missing pubDate field')
      end
    end

    context 'when the feed has an item that is missing the link field' do
      let(:rss_feed_content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog_missing_link.xml').read
      end
      before do
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
        rss_feed_url.news_items.destroy_all
        RssFeedData.new(rss_feed_url).import
      end

      it 'should populate and index just the news items that are valid' do
        expect(rss_feed_url.news_items.count).to eq(2)
      end

      it 'should reflect the missing link field in the last_crawl_status field' do
        expect(rss_feed_url.last_crawl_status).to eq('Missing link field')
      end
    end

    context 'when the feed items have multiple types of problems' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog_2titles_1pubdate.xml').read
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
        rss_feed_url.news_items.destroy_all
        RssFeedData.new(rss_feed_url).import
      end

      it 'should reflect the most common problem in the last_crawl_status field' do
        expect(rss_feed_url.last_crawl_status).to eq("Title can't be blank")
      end
    end

    context 'when a dublin core element is specified multiple times' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog_multiple_dublin_core.xml').read
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
        rss_feed_url.news_items.destroy_all
      end

      it 'should create a single comma-separated list' do
        RssFeedData.new(rss_feed_url).import
        u = RssFeedUrl.find rss_feed_url.id
        newest = u.news_items.first
        expect(newest.subject).to eq('Counterterrorism, Cybersecurity, Global Development, Global Economy, Human Rights, Multilateral Affairs, Nonproliferation, Sub Saharan Africa Middle East and North Africa, East Asia Pacific Europe and Eurasia, South and Central Asia, Western Hemisphere Foreign Policy')
      end
    end

    context 'when the feed is in the RSS 2.0 format' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml').read
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
      end

      context 'when there are no news items associated with the source' do
        before { rss_feed_url.news_items.destroy_all }

        it 'should populate news items from the RSS feed source with HTML stripped from the description' do
          RssFeedData.new(rss_feed_url).import
          u = RssFeedUrl.find rss_feed_url.id
          expect(u.last_crawl_status).to eq('OK')
          expect(u.news_items.count).to eq(3)

          newest = u.news_items.first
          expect(newest.guid).to eq('80731 at http://www.whitehouse.gov')
          expect(newest.link).to eq('http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution')
          expect(newest.published_at).to eq(DateTime.parse('26 Sep 2011 21:33:05 +0000'))
          expect(newest.description[0, 40]).to eq('Dr. Biden and David Letterman refer to a')
          expect(newest.title).to eq('Famine in the Horn of Africa: Be a Part of the Solution')
          expect(newest.contributor).to eq("The President")
          expect(newest.subject).to eq('jobs')
          expect(newest.publisher).to eq("Statements and Releases")

          oldest = u.news_items.last
          expect(oldest.guid).to eq('http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime-0')
          expect(oldest.publisher).to be_nil
        end
      end

      context 'when some news items are newer and some are older than the most recent published_at time for the feed' do
        before do
          rss_feed_url.update_attributes(last_crawl_status: RssFeedUrl::OK_STATUS)
          NewsItem.destroy_all
          rss_feed_url.news_items.create!(
            link: 'http://www.whitehouse.gov/latest_story.html',
            title: 'Big story here',
            description: 'Corps volunteers have promoted blah blah blah.',
            published_at: DateTime.parse('26 Sep 2011 18:31:23 +0000'),
            guid: 'unique')
        end

        context 'when ignore_older_items set to true (default)' do
          it 'should populate news items with only the new ones from the RSS feed source based on the pubDate' do
            RssFeedData.new(rss_feed_url, true).import
            rss_feed_url.reload
            expect(rss_feed_url.last_crawl_status).to eq('OK')
            expect(rss_feed_url.news_items.count).to eq(3)
          end
        end

        context 'when ignore_older_items set to false' do
          it 'should populate news items with both the new and old ones from the RSS feed source based on the pubDate' do
            RssFeedData.new(rss_feed_url, false).import
            rss_feed_url.reload
            expect(rss_feed_url.last_crawl_status).to eq('OK')
            expect(rss_feed_url.news_items.count).to eq(4)
          end
        end
      end

      context 'when there are duplicate news items' do
        before do
          NewsItem.destroy_all
          rss_feed_url.news_items.create!(
            link: 'http://www.whitehouse.gov/latest_story.html',
            title: 'Big story here',
            description: 'Corps volunteers have promoted blah blah blah.',
            published_at: DateTime.parse('26 Sep 2011 18:31:21 +0000'),
            guid: '80671 at http://www.whitehouse.gov')
        end

        it 'should ignore them' do
          RssFeedData.new(rss_feed_url, true).import
          rss_feed_url.reload
          expect(rss_feed_url.last_crawl_status).to eq('OK')
          expect(rss_feed_url.news_items.count).to eq(3)
        end

        context 'when the item links differ only in protocol' do
          let(:rss_feed_content) do
            File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog_diff_protocol.xml').read
          end
          before do
            stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
            NewsItem.destroy_all
          end

          it 'should ignore them' do
            RssFeedData.new(rss_feed_url, true).import
            rss_feed_url.reload
            expect(rss_feed_url.news_items.count).to eq(1)
          end
        end
      end
    end

    context 'when an exception is raised somewhere along the way' do
      before do
        expect(rss_feed_url).to receive(:touch).with(:last_crawled_at).and_raise StandardError.new('Error Message!')
      end

      it 'should log it and move on' do
        expect(Rails.logger).to receive(:warn).once.with(an_instance_of(StandardError))
        RssFeedData.new(rss_feed_url, true).import
        rss_feed_url.reload
        expect(rss_feed_url.last_crawl_status).to eq('Error Message!')
      end
    end

    context 'when the feed uses RSS content module' do
      let(:rss_feed_content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/rss_with_content_module.xml').read
      end
      before do
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
        rss_feed_url.news_items.destroy_all
      end

      it 'creates news item with body' do
        RssFeedData.new(rss_feed_url).import
        u = RssFeedUrl.find rss_feed_url.id
        expect(u.last_crawl_status).to eq('OK')
        expect(u.news_items.count).to eq(2)
        expect(u.news_items.first.body).to include('runs through Oct. 15. It is a special time')

        body = u.news_items.last.body
        expect(body).to start_with('In highly accomplished')
        expect(body).to end_with('accountability. more...')
      end
    end

    context 'when the feed uses media:text and not content:encoded' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/video_rss.xml').read
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
        rss_feed_url.news_items.destroy_all
      end

      it 'should use the media:text for the body' do
        RssFeedData.new(rss_feed_url).import
        u = RssFeedUrl.find rss_feed_url.id
        expect(u.last_crawl_status).to eq('OK')
        expect(u.news_items.count).to eq(2)
        expect(u.news_items.first.body).to include('round beginning Thursday. Randolph Oaks golf course')

        body = u.news_items.last.body
        expect(body).to start_with('MSgt Traci Meduna')
        expect(body).to end_with('very quickly.”')
      end
    end

    context 'when the feed does not contain dublin core namespace' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/rss_without_dublin_core_ns.xml').read
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
      end

      it 'imports news items' do
        RssFeedData.new(rss_feed_url).import
        rss_feed_url.reload
        expect(rss_feed_url.last_crawl_status).to eq('OK')
        expect(rss_feed_url.news_items.count).to eq(30)
      end
    end

    context 'when the feed uses Media RSS with media:content@type' do
      let(:media_rss_url) { rss_feed_urls :media_feed_url }
      let(:rss_feed) { rss_feeds :media_feed }
      let(:affiliate) { affiliates :basic_affiliate }
      let(:rss_feed_content) do
        File.open "#{Rails.root}/spec/fixtures/rss/media_rss_with_media_content_type.xml"
      end

      before do
        stub_request(:get, media_rss_url.url).to_return({ status: 200, body: rss_feed_content })
      end

      it 'should persist media thumbnail and media content properties' do
        RssFeedData.new(media_rss_url).import
        expect(media_rss_url.news_items.reload.count).to eq(3)
        item_with_media_props = media_rss_url.news_items.find_by_link 'http://www.flickr.com/photos/usgeologicalsurvey/8594929349/'

        media_content = item_with_media_props.properties[:media_content]
        expect(media_content).to eq({ url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_b.jpg',
                                  type: 'image/jpeg' })

        media_thumbnail = item_with_media_props.properties[:media_thumbnail]
        expect(media_thumbnail).to eq({ url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_s.jpg' })
        expect(item_with_media_props.tags).to eq(%w(image))

        no_media_content_url_item = media_rss_url.news_items.find_by_link 'http://www.flickr.com/photos/usgeologicalsurvey/8547777933/'
        expect(no_media_content_url_item.properties).to be_empty
        expect(no_media_content_url_item.tags).to be_empty
      end
    end

    context 'when the feed uses Media RSS without media:content@type' do
      let(:media_rss_url) { rss_feed_urls :media_feed_url }
      let(:rss_feed) { rss_feeds :media_feed }
      let(:affiliate) { affiliates :basic_affiliate }
      let(:rss_feed_content) do
        File.open "#{Rails.root}/spec/fixtures/rss/media_rss_without_media_content_type.xml"
      end

      before do
        stub_request(:get, media_rss_url.url).to_return({ status: 200, body: rss_feed_content })
      end

      it 'should persist media thumbnail and media content properties' do
        RssFeedData.new(media_rss_url).import
        expect(media_rss_url.news_items.reload.count).to eq(3)
        link = 'http://www.usgs.gov/blogs/features/usgs_top_story/national-groundwater-awareness-week-2/'
        item_with_media_props = media_rss_url.news_items.find_by_link link

        media_content = item_with_media_props.properties[:media_content]
        expect(media_content).to eq({ url: 'http://www.usgs.gov/blogs/features/files/2014/03/crosssec.jpg',
                                  type: 'image/jpeg' })

        media_thumbnail = item_with_media_props.properties[:media_thumbnail]
        expect(media_thumbnail).to eq({ url: 'http://www.usgs.gov/blogs/features/files/2014/03/crosssec-150x150.jpg' })
        expect(item_with_media_props.tags).to eq(%w(image))
      end
    end

    context 'when the feed is in the Atom format' do
      let(:atom_feed_url) { rss_feed_urls(:atom_feed_url)}
      let(:url) { 'http://www.icpsr.umich.edu/icpsrweb/ICPSR/feeds/studies?fundingAgency=United+States+Department+of+Justice.+Office+of+Justice+Programs.+National+Institute+of+Justice' }
      let(:rss_feed_content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/atom_feed.xml')
      end

      before do
        stub_request(:get, atom_feed_url.url).to_return({ status: 200, body: rss_feed_content })
      end

      context 'when there are no news items associated with the source' do
        it 'should populate news items from the RSS feed source with HTML stripped from the description' do
          RssFeedData.new(atom_feed_url, true).import
          atom_feed_url.reload
          expect(atom_feed_url.news_items.count).to eq(25)
          newest = atom_feed_url.news_items.first
          expect(newest.guid).to eq('http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/22642')
          expect(newest.link).to eq('http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/22642')
          expect(newest.published_at.in_time_zone('EST').iso8601).to eq('2009-11-30T12:00:01-05:00')
          expect(newest.description[0, 40]).to eq('Assessing Consistency and Fairness in Se')
          expect(newest.title).to eq('Assessing Consistency and Fairness in Sentencing in Michigan, Minnesota, and Virginia, 2001-2002, 2004')
        end
      end
    end

    context 'when the Atom feed uses atom:summary instead of atom:content' do
      let(:atom_feed_url) { rss_feed_urls(:atom_feed_url)}
      let(:url) { 'http://www.icpsr.umich.edu/icpsrweb/ICPSR/feeds/studies?fundingAgency=United+States+Department+of+Justice.+Office+of+Justice+Programs.+National+Institute+of+Justice' }

      before do
        rss_feed_content = Rails.root.join('spec/fixtures/rss/feed_with_summary.atom.xml').read
        stub_request(:get, atom_feed_url.url).to_return({ status: 200, body: rss_feed_content })
      end

      it 'saves atom:summary as description' do
        RssFeedData.new(atom_feed_url, true).import
        atom_feed_url.reload
        expect(atom_feed_url.news_items.count).to eq(2)
        newest = atom_feed_url.news_items.first
        expect(newest.title).to eq('4 - Roetter Alexander (0001609815) (Reporting)')
        expect(newest.description).to eq('Filed: 2014-06-04 AccNo: 0001181431-14-022756 Size: 5 KB')
        oldest = atom_feed_url.news_items.last
        expect(oldest.description).to eq('Filed: 2014-06-04 AccNo: 0001181431-14-022755 Size: 8 KB')
      end
    end

    context 'when the RSS feed format can not be determined' do
      let(:rss_feed_content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/unknown_feed_type.xml')
      end

      before do
        rss_feed_url.news_items.destroy_all
        stub_request(:get, rss_feed_url.url).to_return({ status: 200, body: rss_feed_content })
      end

      it 'should not change the number of news items, and update the crawl status' do
        importer = RssFeedData.new(rss_feed_url, true)
        importer.import
        rss_feed_url.reload
        expect(rss_feed_url.news_items.count).to eq(0)
        expect(rss_feed_url.last_crawl_status).to eq('Unknown feed type.')
      end
    end

    context 'when the url has been redirected' do
      let(:rss_feed_url) { rss_feed_urls(:white_house_blog_url) }
      let(:rss_feed_content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml').read
      end

      context 'when the redirection is for a protocol change' do
        before do
          rss_feed_url.news_items.destroy_all
          allow(DocumentFetcher).to receive(:fetch).with(rss_feed_url.url, an_instance_of(Hash)).and_return({ status: "301", body: rss_feed_content, last_effective_url: "https://www.whitehouse.gov/feed/blog/white-house" })
        end

        it 'updates the url' do
           expect{ RssFeedData.new(rss_feed_url, true).import }.to change{ rss_feed_url.reload.url }.
             from("http://www.whitehouse.gov/feed/blog/white-house").
             to("https://www.whitehouse.gov/feed/blog/white-house")
        end

        it 'creates news items' do
          expect{ RssFeedData.new(rss_feed_url, true).import }.to change{ rss_feed_url.news_items.count }.
             from(0).to(3)
        end
      end

      context 'when the redirect is arbitrary' do
        before do
          rss_feed_url.news_items.destroy_all
          allow(DocumentFetcher).to receive(:fetch).with(rss_feed_url.url, an_instance_of(Hash)).
            and_return({ status: "301", body: rss_feed_content, last_effective_url: "http://naughtyponies.com" })
          RssFeedData.new(rss_feed_url, true).import
        end

        it 'does not update the url' do
          expect(rss_feed_url.reload.url).to eq("http://www.whitehouse.gov/feed/blog/white-house")
        end

        it 'does not create any news items' do
          expect(rss_feed_url.news_items.count).to eq 0
        end

        it 'reports the redirection' do
          expect(rss_feed_url.last_crawl_status).to eq "redirection forbidden: http://www.whitehouse.gov/feed/blog/white-house -> http://naughtyponies.com"
        end
      end
    end
  end
end
