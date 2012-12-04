require 'spec_helper'

describe SiteDomainObserver do
  fixtures :affiliates, :features
  let(:affiliate) { affiliates(:power_affiliate) }

  before do
    affiliate.site_domains.create!(:domain => "first.gov")
    affiliate.site_domains.create!(:domain => "second.gov")

    BingSearch.stub(:search_for_url_in_bing).and_return(nil)
    affiliate.indexed_documents.create!(:url => "http://www.first.gov/")
    affiliate.indexed_documents.create!(:url => "http://www.second.gov/")
  end

  context "after the deletion of all but the last SiteDomain for an affiliate" do
    it "should enqueue the revalidation of an affiliate's indexed documents" do
      ResqueSpec.reset!
      affiliate.site_domains.first.destroy
      affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should have_queued(idoc.id) }
      ResqueSpec.reset!
      affiliate.site_domains.first.destroy
      affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should_not have_queued(idoc.id) }
    end
  end

  context "after the alteration of a SiteDomain" do
    it "should enqueue the revalidation of an affiliate's indexed documents" do
      ResqueSpec.reset!
      affiliate.site_domains.first.update_attribute(:domain, "third.gov")
      affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should have_queued(idoc.id) }
    end
  end
end
