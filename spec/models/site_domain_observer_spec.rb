require 'spec/spec_helper'

describe SiteDomainObserver do
  fixtures :affiliates
  let(:affiliate) { affiliates(:power_affiliate) }

  before do
    affiliate.features << Feature.find_or_create_by_internal_name('hosted_sitemaps', :display_name => "hs")
    affiliate.site_domains.create!(:domain => "first.gov")
    affiliate.site_domains.create!(:domain => "second.gov")
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

  context "after the creation of an affiliate's first SiteDomain" do
    before do
      affiliate.site_domains.destroy_all
      ResqueSpec.reset!
    end

    it "should enqueue the revalidation of an affiliate's indexed documents" do
      affiliate.site_domains.create!(:domain => "newone.gov")
      affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should have_queued(idoc.id) }
      ResqueSpec.reset!
      affiliate.site_domains.create!(:domain => "anotherone.gov")
      affiliate.indexed_documents.each { |idoc| IndexedDocumentValidator.should_not have_queued(idoc.id) }
    end

    it "should attempt to crawl/fetch/index documents in the background (at low priority) from that domain and other domains covered by it" do
      Resque.should_receive(:enqueue_with_priority).with(:low, SiteDomainCrawler, an_instance_of(Fixnum))
      affiliate.site_domains.create!(:domain => "newone.gov")
      ResqueSpec.reset!
      Resque.should_not_receive(:enqueue_with_priority).with(:low, SiteDomainCrawler, an_instance_of(Fixnum))
      affiliate.site_domains.create!(:domain => "anotherone.gov")
    end

  end
end
