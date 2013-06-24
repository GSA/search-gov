require 'spec_helper'

describe SiteFeedUrl do
  fixtures :affiliates
  let(:site_feed_url) { SiteFeedUrl.create!(affiliate_id: affiliates(:basic_affiliate).id, rss_url: "http://nps.gov/urls.rss", quota: 3) }

  describe "Creating new instance" do
    it { should belong_to :affiliate }
    it { should validate_presence_of :rss_url }
  end

  describe "#fetch" do
    context 'when fetch succeeds' do
      before do
        HttpConnection.stub(:get).and_return File.read(Rails.root.to_s + "/spec/fixtures/rss/wh_blog.xml")
      end

      it 'should update last_checked_at' do
        lambda {
          site_feed_url.fetch
        }.should change(site_feed_url, :last_checked_at)
      end

      it 'should update the last_fetch_status' do
        site_feed_url.fetch
        site_feed_url.last_fetch_status.should == 'OK'
      end

      it 'should queue up the fetching of the full URL' do
        site_feed_url.affiliate.should_receive(:refresh_indexed_documents).with(IndexedDocument::SUMMARIZED_STATUS)
        site_feed_url.fetch
      end

      it 'should delete any RSS-sourced indexed documents that are not in the feed' do
        links = %w(http://www.whitehouse.gov/blog/2011/09/26/call-peace-perspectives-volunteers-peace-corps-50 http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution)
        IndexedDocument.should_receive(:destroy_all).with(["affiliate_id = ? and url not in (?) and source = 'rss'", site_feed_url.affiliate.id, links])
        site_feed_url.fetch
      end

      it 'should try to create {quota} indexed documents with link, title, desc and summarized status, but not body' do
        site_feed_url.fetch
        idocs = IndexedDocument.last(2)
        idocs.first.url.should == 'http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution'
        idocs.first.title.should == 'Famine in the Horn of Africa: Be a Part of the Solution'
        idocs.first.description.should =~ /FWD them to your neighbors/
        idocs.first.body.should be_nil
        idocs.first.source.should == 'rss'
        idocs.first.last_crawl_status.should == IndexedDocument::SUMMARIZED_STATUS
        idocs.last.url.should == 'http://www.whitehouse.gov/blog/2011/09/26/call-peace-perspectives-volunteers-peace-corps-50'
        idocs.last.title.should == 'A Call to Peace: Perspectives of Volunteers on the Peace Corps at 50'
        idocs.last.description.should =~ /200,000 Peace Corps volunteers/
        idocs.last.body.should be_nil
        idocs.last.source.should == 'rss'
        idocs.last.last_crawl_status.should == IndexedDocument::SUMMARIZED_STATUS
      end
    end

    context 'when an exception occurs fetching the feed' do
      before do
        HttpConnection.stub(:get).and_raise Exception.new("bad!")
      end

      it 'should update the last_fetch_status with the error message' do
        site_feed_url.fetch
        site_feed_url.last_fetch_status.should == 'bad!'
      end
    end

    context 'when a field is missing (title/desc)' do
      before do
        HttpConnection.stub(:get).and_return File.read(Rails.root.to_s + "/spec/fixtures/rss/wh_blog_missing_description_entirely.xml")
        IndexedDocument.destroy_all
      end

      it 'should ignore the invalid records' do
        site_feed_url.fetch
        IndexedDocument.count.should == 1
      end
    end
  end

  describe ".delete" do

    before do
      IndexedDocument.delete_all
      IndexedDocument.create!(title: 'Some Title',
                              description: 'This is a document.',
                              url: 'http://www.nps.gov/index.htm',
                              doctype: 'html',
                              last_crawl_status: IndexedDocument::OK_STATUS,
                              body: "this is the doc body",
                              source: 'rss',
                              affiliate_id: affiliates(:basic_affiliate).id)
      IndexedDocument.create!(title: 'Some Title TWo',
                              description: 'This is another document.',
                              url: 'http://www.nps.gov/index2.htm',
                              doctype: 'html',
                              last_crawl_status: IndexedDocument::OK_STATUS,
                              body: "this is the next doc body",
                              source: 'rss',
                              affiliate_id: affiliates(:basic_affiliate).id)
      IndexedDocument.create!(title: 'Some Title Three',
                              description: 'This is a manually uploaded document.',
                              url: 'http://www.nps.gov/index3.htm',
                              doctype: 'html',
                              last_crawl_status: IndexedDocument::OK_STATUS,
                              body: "this is the next doc body",
                              source: 'manual',
                              affiliate_id: affiliates(:basic_affiliate).id)
      IndexedDocument.reindex
      Sunspot.commit
    end

    it "should batch-delete affiliate's indexed documents as well" do
      IndexedDocument.count.should == 3
      site_feed_url.destroy
      IndexedDocument.count.should == 1
      IndexedDocument.first.title.should == 'Some Title Three'
    end
  end

  describe ".refresh_all" do
    let(:second_one) { SiteFeedUrl.create!(affiliate_id: affiliates(:power_affiliate).id, rss_url: "http://secondone.gov/urls.rss") }

    it "should enqueue the low-priority fetching of all the site feed urls via Resque" do
      ResqueSpec.reset!
      Resque.should_receive(:enqueue_with_priority).with(:low, SiteFeedUrlFetcher, site_feed_url.id)
      Resque.should_receive(:enqueue_with_priority).with(:low, SiteFeedUrlFetcher, second_one.id)
      SiteFeedUrl.refresh_all
    end
  end
end