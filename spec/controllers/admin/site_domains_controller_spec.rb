require 'spec/spec_helper'

describe Admin::SiteDomainsController do
  fixtures :users, :affiliates, :site_domains

  describe "#trigger_crawl" do
    context "when logged in as an affiliate admin" do
      before do
        activate_authlogic
        UserSession.create(:email => users(:affiliate_admin).email, :password => "admin")
        @site_domain = site_domains(:basic)
      end

      it "should trigger a crawl of the site domain" do
        Resque.should_receive(:enqueue_with_priority).with(:low, SiteDomainCrawler, @site_domain.id.to_s)
        get :trigger_crawl, :id => @site_domain.id
        response.should be_success
      end
    end
  end

end
