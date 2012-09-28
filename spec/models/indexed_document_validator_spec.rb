require 'spec_helper'

describe IndexedDocumentValidator, "#perform(indexed_document_id)" do
  fixtures :affiliates, :features, :site_domains

  let(:aff) { affiliates(:basic_affiliate) }
  let(:url) { 'http://nps.gov/pdf.pdf' }
  before do
    aff.indexed_documents.destroy_all
    aff.features << features(:hosted_sitemaps)
    BingSearch.stub(:search_for_url_in_bing).with('http://nps.gov/pdf.pdf').and_return(nil)

    @idoc = aff.indexed_documents.create!(
      :title => 'PDF Title',
      :description => 'This is a PDF document.',
      :url => url,
      :last_crawl_status => IndexedDocument::OK_STATUS,
      :body => "this is the doc body",
      :affiliate_id => affiliates(:basic_affiliate).id,
      :content_hash => "a6e450cc50ac3b3b7788b50b3b73e8b0b7c197c8"
    )
  end

  context "when it can locate the IndexedDocument for an affiliate" do
    before do
      IndexedDocument.stub!(:find_by_id).and_return @idoc
    end

    context "when the IndexedDocument is not valid" do
      before do
        @idoc.stub!(:valid?).and_return false
      end

      it "should destroy the IndexedDocument" do
        @idoc.should_receive(:destroy)
        IndexedDocumentValidator.perform(@idoc.id)
      end

      it "should remove IndexedDocument from solr" do
        IndexedDocument.solr_search_ids { with :affiliate_id, aff.id }.should_not be_blank
        @idoc.should_receive(:remove_from_index)
        IndexedDocumentValidator.perform(@idoc.id)
      end
    end

    context 'when the IndexedDocument url_in_bing is present' do
      let(:normalized_url) { 'nps.gov/pdf.pdf' }
      before do
        BingUrl.destroy_all
        BingSearch.should_receive(:search_for_url_in_bing).with('http://nps.gov/pdf.pdf').and_return(normalized_url)
      end

      it 'should create BingUrl' do
        IndexedDocumentValidator.perform(@idoc.id)
        BingUrl.find_by_normalized_url(normalized_url).should be_present
      end
    end

    context "when the IndexedDocument is valid" do
      before do
        @idoc.stub!(:valid?).and_return true
      end

      it "should not delete the IndexedDocument" do
        @idoc.should_not_receive(:delete)
        IndexedDocumentValidator.perform(@idoc.id)
      end
    end
  end
end