require 'spec/spec_helper'

describe AffiliateIndexedDocumentFetcher, "#perform(affiliate_id, start_id, end_id, scope)" do
  fixtures :affiliates
  before do
    IndexedDocument.destroy_all
    @affiliate = affiliates(:basic_affiliate)
    @unfetched = @affiliate.indexed_documents.build(:url => 'http://some.mil/foo')
    @ok = @affiliate.indexed_documents.build(:title => 'PDF Title',
                                             :description => 'This is a PDF document.',
                                             :url => 'http://something.gov/pdf.pdf',
                                             :last_crawl_status => IndexedDocument::OK_STATUS,
                                             :last_crawled_at => Time.now,
                                             :body => "this is the doc body",
                                             :content_hash => "a6e450cc50ac3b3b7788b50b3b73e8b0b7c197c8")
    @not_ok = @affiliate.indexed_documents.build(:title => 'Dupe PDF Title',
                                                 :description => 'Dupe This is a PDF document.',
                                                 :url => 'http://something.gov/dupe_pdf.pdf',
                                                 :last_crawl_status => 'duplicate',
                                                 :last_crawled_at => Time.now,
                                                 :body => "this is the doc body",
                                                 :content_hash => nil)
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

end