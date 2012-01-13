require 'spec/spec_helper'

describe SiteDomainObserver do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    affiliate.site_domains.create!(:domain => "first.gov")
    affiliate.site_domains.create!(:domain => "second.gov")
    affiliate.indexed_documents.create!(:url=>"http://www.first.gov/")
    affiliate.indexed_documents.create!(:url=>"http://www.second.gov/")
  end

  it "should enqueue the revalidation of an affiliate's indexed documents after the deletion of all but the last SiteDomain for an affiliate" do
    ResqueSpec.reset!
    affiliate.site_domains.first.destroy
    affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should have_queued(idoc.id) }
    ResqueSpec.reset!
    affiliate.site_domains.first.destroy
    affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should_not have_queued(idoc.id) }
  end

  it "should enqueue the revalidation of an affiliate's indexed documents after the alteration of a SiteDomain" do
    ResqueSpec.reset!
    affiliate.site_domains.first.update_attribute(:domain, "third.gov")
    affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should have_queued(idoc.id) }
  end

  it "should enqueue the revalidation of an affiliate's indexed documents after the creation of an affiliate's first SiteDomain" do
    affiliate.site_domains.destroy_all
    ResqueSpec.reset!
    affiliate.site_domains.create!(:domain => "newone.gov")
    affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should have_queued(idoc.id) }
    ResqueSpec.reset!
    affiliate.site_domains.create!(:domain => "anotherone.gov")
    affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should_not have_queued(idoc.id) }
  end
end
