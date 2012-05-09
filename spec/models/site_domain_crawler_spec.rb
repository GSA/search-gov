require 'spec/spec_helper'

describe SiteDomainCrawler, "#perform(site_domain_id)" do

  context "when it can't locate the SiteDomain for a given id" do
    it "should ignore the entry" do
      SiteDomainCrawler.perform(-1)
    end
  end

  context "when it can locate the SiteDomain for an affiliate" do
    let(:site_domain) { mock("site domain") }

    it "should attempt to populate the SiteDomain with indexed documents" do
      SiteDomain.should_receive(:find_by_id).with(1).and_return(site_domain)
      site_domain.should_receive(:populate)
      SiteDomainCrawler.perform(1)
    end
  end
end