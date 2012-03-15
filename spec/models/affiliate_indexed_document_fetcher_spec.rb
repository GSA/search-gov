require 'spec/spec_helper'

describe AffiliateIndexedDocumentFetcher, "#perform(affiliate_id, start_id, end_id, extent)" do
  fixtures :affiliates
  before do
    IndexedDocument.destroy_all
    @affiliate = affiliates(:basic_affiliate)
    @ok = @affiliate.indexed_documents.build(:title => 'PDF Title',
                                             :description => 'This is a PDF document.',
                                             :url => 'http://something.gov/pdf.pdf',
                                             :last_crawl_status => IndexedDocument::OK_STATUS,
                                             :body => "this is the doc body",
                                             :content_hash => "a6e450cc50ac3b3b7788b50b3b73e8b0b7c197c8")
    @not_ok = @affiliate.indexed_documents.build(:title => 'Dupe PDF Title',
                                                 :description => 'Dupe This is a PDF document.',
                                                 :url => 'http://something.gov/dupe_pdf.pdf',
                                                 :last_crawl_status => 'duplicate',
                                                 :body => "this is the doc body",
                                                 :content_hash => nil)
    @unfetched = @affiliate.indexed_documents.build(:url => 'http://some.mil/foo')
    @affiliate.save!
    Affiliate.should_receive(:find).with(@affiliate.id).and_return @affiliate
    @idocs = @affiliate.indexed_documents
    @affiliate.should_receive(:indexed_documents).and_return @idocs
  end

  it "should handle extent 'ok'" do
    @idocs.should_receive(:find_each).with(:batch_size => 100, :conditions => ["last_crawl_status = 'OK' and id between ? and ?", an_instance_of(Fixnum), an_instance_of(Fixnum)]).and_yield(@ok)
    @ok.should_receive(:fetch)
    AffiliateIndexedDocumentFetcher.perform(@affiliate.id, 1, 2, 'ok')
  end

  it "should handle extent 'not_ok'" do
    @idocs.should_receive(:find_each).with(:batch_size => 100, :conditions => ["last_crawl_status <> 'OK' or isnull(last_crawl_status) and id between ? and ?", an_instance_of(Fixnum), an_instance_of(Fixnum)]).and_yield(@not_ok)
    @not_ok.should_receive(:fetch)
    AffiliateIndexedDocumentFetcher.perform(@affiliate.id, 1, 2, 'not_ok')
  end

  it "should handle extent 'unfetched'" do
    @idocs.should_receive(:find_each).with(:batch_size => 100, :conditions => ["isnull(last_crawl_status) and id between ? and ?", an_instance_of(Fixnum), an_instance_of(Fixnum)]).and_yield(@unfetched)
    @unfetched.should_receive(:fetch)
    AffiliateIndexedDocumentFetcher.perform(@affiliate.id, 1, 2, 'unfetched')
  end

  it "should handle default extent 'all'" do
    @idocs.should_receive(:find_each).with(:batch_size => 100, :conditions => ["1=1 and id between ? and ?", an_instance_of(Fixnum), an_instance_of(Fixnum)]).and_yield(@unfetched).and_yield(@not_ok).and_yield(@ok)
    @not_ok.should_receive(:fetch)
    @ok.should_receive(:fetch)
    @unfetched.should_receive(:fetch)
    AffiliateIndexedDocumentFetcher.perform(@affiliate.id, 1, 2, nil)
  end
end