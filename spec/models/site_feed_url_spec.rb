require 'spec_helper'

describe SiteFeedUrl do
  fixtures :affiliates
  let(:site_feed_url) { SiteFeedUrl.create!(affiliate_id: affiliates(:basic_affiliate).id, rss_url: "http://nps.gov/urls.rss", quota: 3) }

  describe "Creating new instance" do
    it { is_expected.to belong_to :affiliate }
    it { is_expected.to validate_presence_of :rss_url }
  end

  describe ".delete" do

    before do
      ElasticIndexedDocument.recreate_index
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
    end

    it "should batch-delete affiliate's indexed documents as well" do
      expect(IndexedDocument.count).to eq(3)
      site_feed_url.destroy
      ElasticIndexedDocument.commit
      expect(IndexedDocument.count).to eq(1)
      expect(IndexedDocument.first.title).to eq('Some Title Three')
      expect(ElasticIndexedDocument.search_for(q: 'some title', affiliate_id: affiliates(:basic_affiliate).id, language: affiliates(:basic_affiliate).indexing_locale).total).to eq(1)
    end
  end

  describe ".refresh_all" do
    let(:second_one) { SiteFeedUrl.create!(affiliate_id: affiliates(:power_affiliate).id, rss_url: "http://secondone.gov/urls.rss") }

    it "should enqueue the low-priority fetching of all the site feed urls via Resque" do
      ResqueSpec.reset!
      expect(Resque).to receive(:enqueue_with_priority).with(:low, SiteFeedUrlFetcher, site_feed_url.id)
      expect(Resque).to receive(:enqueue_with_priority).with(:low, SiteFeedUrlFetcher, second_one.id)
      SiteFeedUrl.refresh_all
    end
  end

  describe '#dup' do
    subject(:original_instance) { site_feed_url }
    include_examples 'site dupable'
  end
end
