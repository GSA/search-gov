# frozen_string_literal: true

describe IndexedDocumentFetcherJob do
  before do
    IndexedDocument.destroy_all
  end

  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:indexed_document) do
    IndexedDocument.create!(
      url: 'https://www.nps.gov/test.html',
      affiliate: affiliate,
      title: 'Document Title 1',
      description: 'This is a Document.'
    )
  end

  it_behaves_like 'a searchgov job'

  context "when it can't locate the IndexedDocument for a given id" do
    it 'ignores the entry' do
      allow(indexed_document).to receive(:fetch)
      described_class.perform_now(indexed_document_id: -1)
      expect(indexed_document).not_to have_received(:fetch)
    end
  end

  context 'when it can locate the Superfresh URL entry for a given url & affiliate_id' do
    before do
      allow(IndexedDocument).to receive(:find_by).and_return indexed_document
    end

    it 'attempts to fetch and index the document' do
      allow(indexed_document).to receive(:fetch)
      described_class.perform_now(indexed_document_id: indexed_document.id)
      expect(indexed_document).to have_received(:fetch)
    end
  end
end
