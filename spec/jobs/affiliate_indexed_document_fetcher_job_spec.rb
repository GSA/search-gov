# frozen_string_literal: true

describe AffiliateIndexedDocumentFetcherJob do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:unfetched) { IndexedDocument.find_by(unfetched_atts) }
  let(:ok) { IndexedDocument.find_by(ok_atts) }
  let(:not_ok) { IndexedDocument.find_by(not_ok_atts) }
  let(:unfetched_atts) do
    { url: 'http://nps.gov/foo.html',
      title: 'Doc Title',
      description: 'This is a document.' }
  end
  let(:ok_atts) do
    { title: 'PDF Title',
      description: 'This is a PDF document.',
      url: 'http://nps.gov/pdf.pdf',
      last_crawl_status: IndexedDocument::OK_STATUS,
      last_crawled_at: Time.zone.now,
      body: 'this is the doc body' }
  end
  let(:not_ok_atts) do
    { title: 'Dupe PDF Title',
      description: 'Dupe This is a PDF document.',
      url: 'http://nps.gov/dupe_pdf.pdf',
      last_crawl_status: 'duplicate',
      last_crawled_at: Time.zone.now,
      body: 'this is the doc body' }
  end

  before do
    IndexedDocument.destroy_all
    affiliate.indexed_documents.build([unfetched_atts, ok_atts, not_ok_atts])
    affiliate.save!
    allow(unfetched).to receive(:fetch)
  end

  it "handles scope 'ok'" do
    allow(IndexedDocument).to receive(:find).and_return(ok)
    allow(ok).to receive(:fetch)
    described_class.perform_now(affiliate.id, 1, 2**30, 'ok')
    expect(IndexedDocument).to have_received(:find).once.with(ok.id)
    expect(ok).to have_received(:fetch)
  end

  it "handles scope 'not_ok'" do
    allow(IndexedDocument).to receive(:find).and_return(not_ok, unfetched)
    allow(not_ok).to receive(:fetch)
    described_class.perform_now(affiliate.id, 1, 2**30, 'not_ok')
    expect(IndexedDocument).to have_received(:find).with(not_ok.id)
    expect(IndexedDocument).to have_received(:find).with(unfetched.id)
    expect(not_ok).to have_received(:fetch)
    expect(unfetched).to have_received(:fetch)
  end

  context 'when the scope is unfetched' do
    it "handles scope 'unfetched'" do
      allow(IndexedDocument).to receive(:find).and_return(unfetched)
      described_class.perform_now(affiliate.id, 1, 2**30, 'unfetched')
      expect(IndexedDocument).to have_received(:find).once.with(unfetched.id)
      expect(unfetched).to have_received(:fetch)
    end
  end

  context 'when an indexed document has disappeared before job runs' do
    let(:unfetched2) { IndexedDocument.find_by(unfetched_atts2) }
    let(:unfetched_atts2) do
      { url: 'http://nps.gov/foo2.html',
        title: 'Doc Title 2',
        description: 'This is a document 2.' }
    end

    before do
      affiliate.indexed_documents.build(unfetched_atts2)
      affiliate.save
      allow(IndexedDocument).to receive(:find).with(unfetched.id).and_raise ActiveRecord::RecordNotFound
      allow(IndexedDocument).to receive(:find).with(unfetched2.id).and_return(unfetched2)
      allow(unfetched2).to receive(:fetch)
      allow(Rails.logger).to receive(:warn)
    end

    it 'logs the problem and moves on' do
      described_class.perform_now(affiliate.id, 1, 2**30, 'unfetched')
      expect(Rails.logger).to have_received(:warn).with(/Cannot find IndexedDocument to fetch/)
    end

    it 'fetches the good document' do
      described_class.perform_now(affiliate.id, 1, 2**30, 'unfetched')
      expect(unfetched2).to have_received(:fetch)
    end

    it 'does not fetch the missing document' do
      described_class.perform_now(affiliate.id, 1, 2**30, 'unfetched')
      expect(unfetched).not_to have_received(:fetch)
    end
  end

  context 'when the affiliate has disappeared before job runs' do
    before do
      allow(Affiliate).to receive(:find).and_raise ActiveRecord::RecordNotFound
      allow(Rails.logger).to receive(:warn)
    end

    it 'logs the problem and moves on' do
      described_class.perform_now(affiliate.id, 1, 2**30, 'unfetched')
      expect(Rails.logger).to have_received(:warn).with(/Ignoring race condition in AffiliateIndexedDocumentFetcherJob/)
    end
  end
end
