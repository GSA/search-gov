require 'spec_helper'

describe IndexedDocumentFetcher, '#perform(indexed_document_id)' do
  fixtures :affiliates, :features
  before do
    affiliate = affiliates(:basic_affiliate)

    IndexedDocument.destroy_all
    @indexed_document = IndexedDocument.create!(:url => 'http://www.nps.gov/test.html', :affiliate => affiliate, :title => 'Document Title 1', :description => 'This is a Document.')
  end

  it_behaves_like 'a ResqueJobStats job'

  context "when it can't locate the IndexedDocument for a given id" do
    it 'should ignore the entry' do
      expect(@indexed_document).not_to receive(:fetch)
      IndexedDocumentFetcher.perform(-1)
    end
  end

  context 'when it can locate the Superfresh URL entry for a given url & affiliate_id' do
    before do
      allow(IndexedDocument).to receive(:find_by_id).and_return @indexed_document
    end

    it 'should attempt to fetch and index the document' do
      expect(@indexed_document).to receive(:fetch)
      IndexedDocumentFetcher.perform(@indexed_document.id)
    end
  end
end
