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
        allow(HttpConnection).to receive(:get).and_return Rails.root.join('spec/fixtures/rss/site_feed.xml').read
      end

      it 'should update last_checked_at' do
        expect {
          described_class.new(site_feed_url).import
        }.to change(site_feed_url, :last_checked_at)
      end

      it 'should update the last_fetch_status' do
        described_class.new(site_feed_url).import
        expect(site_feed_url.last_fetch_status).to eq('OK')
      end

      it 'should queue up the fetching of the full URL' do
        expect(site_feed_url.affiliate).to receive(:refresh_indexed_documents).with(IndexedDocument::SUMMARIZED_STATUS)
        described_class.new(site_feed_url).import
      end

      it 'should delete any RSS-sourced indexed documents that are not in the feed' do
        obsolete_doc = IndexedDocument.create!(affiliate_id: site_feed_url.affiliate.id,
                                               url: 'http://www.whitehouse.gov/blog/2011/obsolete-document',
                                               title: 'obsolete document title',
                                               description: 'obsolete document description')
        expect(IndexedDocument).to receive(:fast_delete).with([obsolete_doc.id])
        described_class.new(site_feed_url).import
      end

      it 'should try to create {quota} indexed documents with link, title, desc and summarized status, but not body' do
        described_class.new(site_feed_url).import
        idocs = IndexedDocument.last(3)
        expect(idocs.first.url).to eq('http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution')
        expect(idocs.first.title).to eq('Famine in the Horn of Africa: Be a Part of the Solution')
        expect(idocs.first.description).to match(/FWD them to your neighbors/)
        expect(idocs.first.body).to be_nil
        expect(idocs.first.source).to eq('rss')
        expect(idocs.first.last_crawl_status).to eq(IndexedDocument::SUMMARIZED_STATUS)
        expect(idocs[1].url).to eq('http://www.whitehouse.gov/blog/2011/09/26/call-peace-perspectives-volunteers-peace-corps-50')
        expect(idocs[1].title).to eq('A Call to Peace: Perspectives of Volunteers on the Peace Corps at 50 (no pubDate)')
        expect(idocs[1].description).to match(/200,000 Peace Corps volunteers/)
        expect(idocs[1].body).to be_nil
        expect(idocs[1].source).to eq('rss')
        expect(idocs[1].last_crawl_status).to eq(IndexedDocument::SUMMARIZED_STATUS)
        expect(idocs.last.url).to eq('http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime-0')
        expect(idocs.last.title).to eq('Supporting Scientists at the Lab Bench ... and at Bedtime')
        expect(idocs.last.description).to match(/from the Office of Science and Technology/)
        expect(idocs.last.body).to be_nil
        expect(idocs.last.source).to eq('rss')
        expect(idocs.last.last_crawl_status).to eq(IndexedDocument::SUMMARIZED_STATUS)
      end
    end

    context 'when updating existing indexed documents' do
      before do
        allow(HttpConnection).to receive(:get).
          and_return(Rails.root.join('spec/fixtures/rss/site_feed.xml').read,
                     Rails.root.join('spec/fixtures/rss/site_feed_updated.xml').read)
      end

      it 'updates only documents with newer pubDate' do
        described_class.new(site_feed_url).import
        site_feed_url.affiliate.indexed_documents.where(source: 'rss').update_all(last_crawl_status: IndexedDocument::OK_STATUS)

        described_class.new(site_feed_url).import

        idocs = IndexedDocument.last(3)
        expect(idocs.first.url).to eq('http://www.whitehouse.gov/blog/2011/09/26/famine-horn-africa-be-part-solution')
        expect(idocs.first.title).to eq('Famine in the Horn of Africa: Be a Part of the Solution')
        expect(idocs.first.description).to match(/FWD them to your neighbors/)
        expect(idocs.first.last_crawl_status).to eq(IndexedDocument::OK_STATUS)

        expect(idocs[1].url).to eq('http://www.whitehouse.gov/blog/2011/09/26/call-peace-perspectives-volunteers-peace-corps-50')
        expect(idocs[1].title).to eq('A Call to Peace: Perspectives of Volunteers on the Peace Corps at 50 (updated)')
        expect(idocs[1].description).to match(/200,000 Peace Corps volunteers/)
        expect(idocs[1].last_crawl_status).to eq(IndexedDocument::SUMMARIZED_STATUS)

        expect(idocs.last.url).to eq('http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime-0')
        expect(idocs.last.title).to eq('Supporting Scientists at the Lab Bench ... and at Bedtime (updated)')
        expect(idocs.last.description).to match(/from the Office of Science and Technology/)
        expect(idocs.last.last_crawl_status).to eq(IndexedDocument::SUMMARIZED_STATUS)
      end
    end

    context 'when updated feed is blank' do
      before do
        allow(HttpConnection).to receive(:get).
          and_return(Rails.root.join('spec/fixtures/rss/site_feed.xml').read,
                     Rails.root.join('spec/fixtures/rss/site_feed_blank.xml').read)
      end

      it 'updates only documents with newer pubDate' do
        described_class.new(site_feed_url).import

        obsolete_ids = IndexedDocument.order(:id).pluck(:id)
        expect(IndexedDocument).to receive(:fast_delete).with(obsolete_ids)
        described_class.new(site_feed_url).import
      end
    end

    context 'when an exception occurs fetching the feed' do
      before do
        allow(HttpConnection).to receive(:get).and_raise Exception.new('bad!')
      end

      it 'should update the last_fetch_status with the error message' do
        described_class.new(site_feed_url).import
        expect(site_feed_url.last_fetch_status).to eq('bad!')
      end
    end

    context 'when feed has more items than quota' do
      before do
        allow(HttpConnection).to receive(:get).and_return Rails.root.join('spec/fixtures/rss/site_feed.xml').read
        site_feed_url.quota = 2
      end

      it 'should just parse within the quota' do
        described_class.new(site_feed_url).import
        expect(IndexedDocument.count).to eq(2)
      end
    end

    context 'when feed has fewer items than quota' do
      before do
        allow(HttpConnection).to receive(:get).and_return Rails.root.join('spec/fixtures/rss/site_feed.xml').read
        site_feed_url.quota = 1000
      end

      it 'should just parse what is there' do
        described_class.new(site_feed_url).import
        expect(IndexedDocument.count).to eq(3)
      end
    end
  end
end
