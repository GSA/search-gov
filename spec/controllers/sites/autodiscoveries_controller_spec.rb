require 'spec_helper'

describe Sites::AutodiscoveriesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }
  let(:site_autodiscoverer) { mock(SiteAutodiscoverer) }

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :get, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context "when a valid autodiscovery_url is provided" do
        let(:autodiscovery_url) { "http://usa.gov" }

        before do
          SiteAutodiscoverer.should_receive(:new).with(site, autodiscovery_url).and_return site_autodiscoverer
          site_autodiscoverer.should_receive(:run)
          post :create, id: site.id, autodiscovery_url: autodiscovery_url
        end

        it { should redirect_to(site_content_path(site)) }
        it "should set the flash to reflect success and preserve the autodiscovery_url" do
          expect(flash[:success]).to eq("Discovery complete for #{autodiscovery_url}")
          expect(flash[:autodiscovery_url]).to eq(autodiscovery_url)
        end
      end

      context "when an invalid autodiscovery_url is invalid" do
        let(:autodiscovery_url) { "http://_" }
        before do
          SiteAutodiscoverer.should_receive(:new).with(site, autodiscovery_url).and_raise URI::InvalidURIError
          post :create, id: site.id, autodiscovery_url: autodiscovery_url
        end

        it { should redirect_to(site_content_path(site)) }
        it "should set the flash to reflect success and preserve the autodiscovery_url" do
          expect(flash[:error]).to eq("Invalid site URL #{autodiscovery_url}")
          expect(flash[:autodiscovery_url]).to eq(autodiscovery_url)
        end
      end

      context "when no autodiscovery_url is provided" do
        it "raises a 400 error" do
          post :create, id: site.id
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
