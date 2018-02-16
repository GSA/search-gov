require 'spec_helper'

describe Sites::AutodiscoveriesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }
  let(:site_autodiscoverer) { double(SiteAutodiscoverer) }

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :get, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context "when a valid autodiscovery_url is provided" do
        render_views
        let(:autodiscovery_url) { "https://www.usa.gov" }

        before do
          expect(SiteAutodiscoverer).to receive(:new).with(site, autodiscovery_url).and_return site_autodiscoverer
          expect(site_autodiscoverer).to receive(:run)
          allow(site_autodiscoverer).to receive(:discovered_resources)
          post :create, site_id: site.id, autodiscovery_url: autodiscovery_url
        end

        it { is_expected.to redirect_to(site_content_path(site)) }
        it "should set the flash to reflect success and preserve the autodiscovery_url" do
          expect(flash[:success]).to match("Discovery complete for #{autodiscovery_url}")
          expect(flash[:autodiscovery_url]).to eq(autodiscovery_url)
        end
      end

      context "when an invalid autodiscovery_url is invalid" do
        let(:autodiscovery_url) { "http://_" }
        before do
          expect(SiteAutodiscoverer).to receive(:new).with(site, autodiscovery_url).and_raise URI::InvalidURIError
          post :create, site_id: site.id, autodiscovery_url: autodiscovery_url
        end

        it { is_expected.to redirect_to(site_content_path(site)) }
        it "should set the flash to reflect success and preserve the autodiscovery_url" do
          expect(flash[:error]).to eq("Invalid site URL #{autodiscovery_url}")
          expect(flash[:autodiscovery_url]).to eq(autodiscovery_url)
        end
      end

      context "when no autodiscovery_url is provided" do
        it "raises a 400 error" do
          post :create, site_id: site.id
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
