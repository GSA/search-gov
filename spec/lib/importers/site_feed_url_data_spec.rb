require 'spec_helper'

describe SiteFeedUrlData do
  fixtures :affiliates

  let(:site_feed_url) do
    SiteFeedUrl.create!(affiliate_id: affiliates(:basic_affiliate).id,
                        rss_url: 'http://nps.gov/urls.rss',
                        quota: 3)
  end

  describe '#import' do
    context 'when fetch succeeds' do
      before do
        HttpConnection.stub(:get).and_return Rails.root.join('spec/fixtures/rss/site_feed.xml').read
      end

      it 'should update last_checked_at' do
        lambda {
          SiteFeedUrlData.new(site_feed_url).import
        }.should change(site_feed_url, :last_checked_at)
      end

      it 'should update the last_fetch_status' do
        SiteFeedUrlData.new(site_feed_url).import
        site_feed_url.last_fetch_status.should == 'OK'
      end

      it 'should queue up the fetching of the full URL' do
        site_feed_url.affiliate.should_receive(:refresh_indexed_documents).with(IndexedDocument::SUMMARIZED_STATUS)
        SiteFeedUrlData.new(site_feed_url).import
      end

      it 'should delete any RSS-sourced indexed documents that are not in the feed' do
        obsolete_doc = IndexedDocument.create!(affiliate_id: site_feed_url.affiliate.id,
                                               url: 'http://www.whitehouse.gov/blog/2011/obsolete-document',
                                               title: 'obsolete document title',
                                               description: 'obsolete document description')
        IndexedDocument.should_receive(:fast_delete).with([obsolete_doc.id])
        SiteFeedUrlData.new(site_feed_url).import
      end

      it 'should try to create {quota} indexed documents with link, title, desc and summarized status, but not body' do
        SiteFeedUrlData.new(site_feed_url).import
        idocs = IndexedDocument.last(3)
        idocs.first.url.should == 'http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution'
        idocs.first.title.should == 'Famine in the Horn of Africa: Be a Part of the Solution'
        idocs.first.description.should =~ /FWD them to your neighbors/
        idocs.first.body.should be_nil
        idocs.first.source.should == 'rss'
        idocs.first.last_crawl_status.should == IndexedDocument::SUMMARIZED_STATUS
        idocs[1].url.should == 'http://www.whitehouse.gov/blog/2011/09/26/call-peace-perspectives-volunteers-peace-corps-50'
        idocs[1].title.should == 'A Call to Peace: Perspectives of Volunteers on the Peace Corps at 50 (no pubDate)'
        idocs[1].description.should =~ /200,000 Peace Corps volunteers/
        idocs[1].body.should be_nil
        idocs[1].source.should == 'rss'
        idocs[1].last_crawl_status.should == IndexedDocument::SUMMARIZED_STATUS
        idocs.last.url.should == 'http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime-0'
        idocs.last.title.should == 'Supporting Scientists at the Lab Bench ... and at Bedtime'
        idocs.last.description.should =~ /from the Office of Science and Technology/
        idocs.last.body.should be_nil
        idocs.last.source.should == 'rss'
        idocs.last.last_crawl_status.should == IndexedDocument::SUMMARIZED_STATUS
      end
    end

    context 'when updating existing indexed documents' do
      before do
        HttpConnection.stub(:get).
          and_return(Rails.root.join('spec/fixtures/rss/site_feed.xml').read,
                     Rails.root.join('spec/fixtures/rss/site_feed_updated.xml').read)
      end

      it 'updates only documents with newer pubDate' do
        SiteFeedUrlData.new(site_feed_url).import
        site_feed_url.affiliate.indexed_documents.where(source: 'rss').update_all(last_crawl_status: IndexedDocument::OK_STATUS)

        SiteFeedUrlData.new(site_feed_url).import

        idocs = IndexedDocument.last(3)
        idocs.first.url.should == 'http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution'
        idocs.first.title.should == 'Famine in the Horn of Africa: Be a Part of the Solution'
        idocs.first.description.should =~ /FWD them to your neighbors/
        idocs.first.last_crawl_status.should == IndexedDocument::OK_STATUS

        idocs[1].url.should == 'http://www.whitehouse.gov/blog/2011/09/26/call-peace-perspectives-volunteers-peace-corps-50'
        idocs[1].title.should == 'A Call to Peace: Perspectives of Volunteers on the Peace Corps at 50 (updated)'
        idocs[1].description.should =~ /200,000 Peace Corps volunteers/
        idocs[1].last_crawl_status.should == IndexedDocument::SUMMARIZED_STATUS

        idocs.last.url.should == 'http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime-0'
        idocs.last.title.should == 'Supporting Scientists at the Lab Bench ... and at Bedtime (updated)'
        idocs.last.description.should =~ /from the Office of Science and Technology/
        idocs.last.last_crawl_status.should == IndexedDocument::SUMMARIZED_STATUS
      end
    end

    context 'when updated feed is blank' do
      before do
        HttpConnection.stub(:get).
          and_return(Rails.root.join('spec/fixtures/rss/site_feed.xml').read,
                     Rails.root.join('spec/fixtures/rss/site_feed_blank.xml').read)
      end

      it 'updates only documents with newer pubDate' do
        SiteFeedUrlData.new(site_feed_url).import

        obsolete_ids = IndexedDocument.order(:id).pluck(:id)
        IndexedDocument.should_receive(:fast_delete).with(obsolete_ids)
        SiteFeedUrlData.new(site_feed_url).import
      end
    end

    context 'when an exception occurs fetching the feed' do
      before do
        HttpConnection.stub(:get).and_raise Exception.new('bad!')
      end

      it 'should update the last_fetch_status with the error message' do
        SiteFeedUrlData.new(site_feed_url).import
        site_feed_url.last_fetch_status.should == 'bad!'
      end
    end

    context 'when a field is missing (title/desc)' do
      before do
        HttpConnection.stub(:get).and_return Rails.root.join('spec/fixtures/rss/wh_blog_missing_description_entirely.xml').read
        IndexedDocument.destroy_all
      end

      it 'should ignore the invalid records' do
        SiteFeedUrlData.new(site_feed_url).import
        IndexedDocument.count.should == 1
      end
    end

    context 'when feed has more items than quota' do
      before do
        HttpConnection.stub(:get).and_return Rails.root.join('spec/fixtures/rss/site_feed.xml').read
        site_feed_url.quota = 2
      end

      it 'should just parse within the quota' do
        SiteFeedUrlData.new(site_feed_url).import
        IndexedDocument.count.should == 2
      end
    end

    context 'when feed has fewer items than quota' do
      before do
        HttpConnection.stub(:get).and_return Rails.root.join('spec/fixtures/rss/site_feed.xml').read
        site_feed_url.quota = 1000
      end

      it 'should just parse what is there' do
        SiteFeedUrlData.new(site_feed_url).import
        IndexedDocument.count.should == 3
      end
    end
  end
end
