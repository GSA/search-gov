require 'spec_helper'

describe AffiliateIndexedDocumentFetcher, "#perform(affiliate_id, start_id, end_id, scope)" do
  fixtures :affiliates, :features, :site_domains
  before do
    IndexedDocument.destroy_all
    @affiliate = affiliates(:basic_affiliate)
    @unfetched = @affiliate.indexed_documents.build(:url => 'http://nps.gov/foo.html', :title => 'Doc Title',
                                                    :description => 'This is a document.')
    @ok = @affiliate.indexed_documents.build(:title => 'PDF Title',
                                             :description => 'This is a PDF document.',
                                             :url => 'http://nps.gov/pdf.pdf',
                                             :last_crawl_status => IndexedDocument::OK_STATUS,
                                             :last_crawled_at => Time.now,
                                             :body => "this is the doc body")
    @not_ok = @affiliate.indexed_documents.build(:title => 'Dupe PDF Title',
                                                 :description => 'Dupe This is a PDF document.',
                                                 :url => 'http://nps.gov/dupe_pdf.pdf',
                                                 :last_crawl_status => 'duplicate',
                                                 :last_crawled_at => Time.now,
                                                 :body => "this is the doc body")
    @affiliate.save!
  end

  it "should handle scope 'ok'" do
    IndexedDocument.should_receive(:find).once.with(@ok.id).and_return @ok
    @ok.should_receive(:fetch)
    AffiliateIndexedDocumentFetcher.perform(@affiliate.id, 1, 2**30, 'ok')
  end

  it "should handle scope 'not_ok'" do
    IndexedDocument.should_receive(:find).with(@not_ok.id).and_return @not_ok
    IndexedDocument.should_receive(:find).with(@unfetched.id).and_return @unfetched
    @unfetched.should_receive(:fetch)
    @not_ok.should_receive(:fetch)
    AffiliateIndexedDocumentFetcher.perform(@affiliate.id, 1, 2**30, 'not_ok')
  end

  it "should handle scope 'unfetched'" do
    IndexedDocument.should_receive(:find).once.with(@unfetched.id).and_return @unfetched
    @unfetched.should_receive(:fetch)
    AffiliateIndexedDocumentFetcher.perform(@affiliate.id, 1, 2**30, 'unfetched')
  end

  context "when affiliate or indexed document have disappeared before job runs" do
    before do
      IndexedDocument.stub!(:find).and_raise ActiveRecord::RecordNotFound
    end

    it "should ignore the problem and move on" do
      AffiliateIndexedDocumentFetcher.perform(@affiliate.id, 1, 2**30, 'unfetched')
    end
  end

end