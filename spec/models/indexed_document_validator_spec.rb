require 'spec_helper'

describe IndexedDocumentValidator, '#perform(indexed_document_id)' do
  fixtures :affiliates, :features, :site_domains

  let(:aff) { affiliates(:basic_affiliate) }
  let(:url) { 'http://nps.gov/pdf.pdf' }
  before do
    aff.indexed_documents.destroy_all

    @idoc = aff.indexed_documents.create!(
      title: 'PDF Title',
      description: 'This is a PDF document.',
      url: url,
      last_crawl_status: IndexedDocument::OK_STATUS,
      body: 'this is the doc body',
      affiliate_id: affiliates(:basic_affiliate).id
    )
  end

  it_behaves_like 'a ResqueJobStats job'

  context 'when it can locate the IndexedDocument for an affiliate' do
    before do
      allow(IndexedDocument).to receive(:find_by_id).and_return @idoc
    end

    context 'when the IndexedDocument is not valid' do
      before do
        allow(@idoc).to receive(:valid?).and_return false
      end

      it 'should destroy the IndexedDocument' do
        expect(@idoc).to receive(:destroy)
        IndexedDocumentValidator.perform(@idoc.id)
      end

    end

    context 'when the IndexedDocument is valid' do
      before do
        allow(@idoc).to receive(:valid?).and_return true
      end

      it 'should not delete the IndexedDocument' do
        expect(@idoc).not_to receive(:delete)
        IndexedDocumentValidator.perform(@idoc.id)
      end
    end
  end
end
