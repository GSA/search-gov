require 'spec_helper'

describe RssFeedData do
  disconnect_sunspot
  fixtures :affiliates, :rss_feeds, :rss_feed_urls

  describe '#import' do
    let(:rss_feed_url) { rss_feed_urls(:basic_url) }

    context 'when the feed has an item that fails validation' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog_missing_description.xml').read
        HttpConnection.should_receive(:get).with('http://some.agency.gov/feed').and_return(rss_feed_content)
        rss_feed_url.news_items.destroy_all
      end

      it 'should populate and index just the news items that are valid' do
        RssFeedData.new(rss_feed_url).import
        u = RssFeedUrl.find rss_feed_url.id
        u.last_crawl_status.should == 'OK'
        u.news_items.count.should == 2
      end
    end

    context 'when the feed is in the RSS 2.0 format' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml').read
        HttpConnection.should_receive(:get).with('http://some.agency.gov/feed').and_return(rss_feed_content)
      end

      context 'when there are no news items associated with the source' do
        before { rss_feed_url.news_items.destroy_all }

        it 'should populate news items from the RSS feed source with HTML stripped from the description' do
          RssFeedData.new(rss_feed_url).import
          u = RssFeedUrl.find rss_feed_url.id
          u.last_crawl_status.should == 'OK'
          u.news_items.count.should == 3

          newest = u.news_items.first
          newest.guid.should == '80731 at http://www.whitehouse.gov'
          newest.link.should == 'http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution'
          newest.published_at.should == DateTime.parse('26 Sep 2011 21:33:05 +0000')
          newest.description[0, 40].should == 'Dr. Biden and David Letterman refer to a'
          newest.title.should == 'Famine in the Horn of Africa: Be a Part of the Solution'
          newest.contributor.should == "The President"
          newest.subject.should == 'jobs'
          newest.publisher.should == "Statements and Releases"

          oldest = u.news_items.last
          oldest.guid.should == 'http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime-0'
          oldest.publisher.should be_nil
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
            rss_feed_url.last_crawl_status.should == 'OK'
            rss_feed_url.news_items.count.should == 3
          end
        end

        context 'when ignore_older_items set to false' do
          it 'should populate news items with both the new and old ones from the RSS feed source based on the pubDate' do
            RssFeedData.new(rss_feed_url, false).import
            rss_feed_url.reload
            rss_feed_url.last_crawl_status.should == 'OK'
            rss_feed_url.news_items.count.should == 4
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
          rss_feed_url.last_crawl_status.should == 'OK'
          rss_feed_url.news_items.count.should == 3
        end
      end

      context 'when an exception is raised somewhere along the way' do
        before { DateTime.should_receive(:parse).and_raise Exception.new('Error Message!') }

        it 'should log it and move on' do
          Rails.logger.should_receive(:warn).once.with(an_instance_of(Exception))
          RssFeedData.new(rss_feed_url, true).import
          rss_feed_url.reload
          rss_feed_url.last_crawl_status.should == 'Error Message!'
        end
      end
    end

    context 'when the feed uses Media RSS' do
      let(:media_rss_url) { rss_feed_urls :media_feed_url }
      let(:rss_feed) { rss_feeds :media_feed }
      let(:affiliate) { affiliates :basic_affiliate }
      before do
        rss_feed_content = File.open "#{Rails.root}/spec/fixtures/rss/media_rss.xml"
        HttpConnection.should_receive(:get).with(media_rss_url.url).and_return rss_feed_content
      end

      it 'should persist media thumbnail and media content properties' do
        RssFeedData.new(media_rss_url).import
        media_rss_url.news_items(true).count.should == 3
        item_with_media_props = media_rss_url.news_items.find_by_link 'http://www.flickr.com/photos/usgeologicalsurvey/8594929349/'

        media_content = item_with_media_props.properties[:media_content]
        media_content.should == { url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_b.jpg',
                                  type: 'image/jpeg' }

        media_thumbnail = item_with_media_props.properties[:media_thumbnail]
        media_thumbnail.should == { url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_s.jpg' }
        item_with_media_props.tags.should == %w(image)

        no_media_content_url_item = media_rss_url.news_items.find_by_link 'http://www.flickr.com/photos/usgeologicalsurvey/8547777933/'
        no_media_content_url_item.properties.should be_empty
        no_media_content_url_item.tags.should be_empty
      end
    end

    context 'when the feed is in the Atom format' do
      let(:atom_feed_url) { rss_feed_urls(:atom_feed_url)}
      let(:url) { 'http://www.icpsr.umich.edu/icpsrweb/ICPSR/feeds/studies?fundingAgency=United+States+Department+of+Justice.+Office+of+Justice+Programs.+National+Institute+of+Justice' }

      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/atom_feed.xml')
        HttpConnection.should_receive(:get).with(url).and_return rss_feed_content
      end

      context 'when there are no news items associated with the source' do
        it 'should populate news items from the RSS feed source with HTML stripped from the description' do
          RssFeedData.new(atom_feed_url, true).import
          atom_feed_url.reload
          atom_feed_url.news_items.count.should == 25
          newest = atom_feed_url.news_items.first
          newest.guid.should == 'http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/22642'
          newest.link.should == 'http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/22642'
          newest.published_at.should == DateTime.parse('2009-11-30T12:00:00-05:00')
          newest.description[0, 40].should == 'Assessing Consistency and Fairness in Se'
          newest.title.should == 'Assessing Consistency and Fairness in Sentencing in Michigan, Minnesota, and Virginia, 2001-2002, 2004'
        end
      end
    end

    context 'when the RSS feed format can not be determined' do
      let(:url) { 'http://some.agency.gov/feed' }

      before do
        rss_feed_url.news_items.destroy_all
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/atom_feed.xml')
        HttpConnection.should_receive(:get).with(url).and_return rss_feed_content
      end

      it 'should not change the number of news items, and update the crawl status' do
        importer = RssFeedData.new(rss_feed_url, true)
        importer.should_receive(:detect_feed_type).and_return(nil)
        importer.import
        rss_feed_url.reload
        rss_feed_url.news_items.count.should == 0
        rss_feed_url.last_crawl_status.should == 'Unknown feed type.'
      end
    end
  end

  describe '.determine_media_type_from_url' do
    it 'should identify images' do
      %w(gif JPEG png).each do |ext|
        url = "http://some.agency.gov/media.#{ext}"
        RssFeedData.determine_media_type_from_url(url).should == "image/#{ext.downcase}"
      end
    end
  end
end
