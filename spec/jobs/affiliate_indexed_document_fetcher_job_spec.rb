require 'spec_helper'

describe AffiliateIndexedDocumentFetcherJob do
  before do
    IndexedDocument.destroy_all
    @affiliate = affiliates(:basic_affiliate)
    @unfetched = @affiliate.indexed_documents.build(url: 'http://nps.gov/foo.html', title: 'Doc Title',
                                                    description: 'This is a document.')
    @ok = @affiliate.indexed_documents.build(title: 'PDF Title',
                                             description: 'This is a PDF document.',
                                             url: 'http://nps.gov/pdf.pdf',
                                             last_crawl_status: IndexedDocument::OK_STATUS,
                                             last_crawled_at: Time.now,
                                             body: 'this is the doc body')
    @not_ok = @affiliate.indexed_documents.build(title: 'Dupe PDF Title',
                                                 description: 'Dupe This is a PDF document.',
                                                 url: 'http://nps.gov/dupe_pdf.pdf',
                                                 last_crawl_status: 'duplicate',
                                                 last_crawled_at: Time.now,
                                                 body: 'this is the doc body')
    @affiliate.save!
  end

  it "handles scope 'ok'" do
    expect(IndexedDocument).to receive(:find).once.with(@ok.id).and_return @ok
    expect(@ok).to receive(:fetch)
    described_class.perform_now(@affiliate.id, 1, 2**30, 'ok')
  end

  it "handles scope 'not_ok'" do
    expect(IndexedDocument).to receive(:find).with(@not_ok.id).and_return @not_ok
    expect(IndexedDocument).to receive(:find).with(@unfetched.id).and_return @unfetched
    expect(@unfetched).to receive(:fetch)
    expect(@not_ok).to receive(:fetch)
    described_class.perform_now(@affiliate.id, 1, 2**30, 'not_ok')
  end

  it "handles scope 'unfetched'" do
    expect(IndexedDocument).to receive(:find).once.with(@unfetched.id).and_return @unfetched
    expect(@unfetched).to receive(:fetch)
    described_class.perform_now(@affiliate.id, 1, 2**30, 'unfetched')
  end

  context 'when affiliate or indexed document have disappeared before job runs' do
    before do
      allow(IndexedDocument).to receive(:find).and_raise ActiveRecord::RecordNotFound
      allow(Rails.logger).to receive(:warn)
    end

    it 'logs the problem and moves on' do
      described_class.perform_now(@affiliate.id, 1, 2**30, 'unfetched')
      expect(Rails.logger).to have_received(:warn).with(/Ignoring race condition in AffiliateIndexedDocumentFetcherJob/)
    end
  end
end
