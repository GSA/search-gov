require 'spec_helper'

describe Sites::AutodiscoveriesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }
  let(:site_autodiscoverer) { mock(SiteAutodiscoverer) }

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :get, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        SiteAutodiscoverer.should_receive(:new).with(site).and_return site_autodiscoverer
        site_autodiscoverer.should_receive(:run)
        post :create, id: site.id
      end

      it { should redirect_to(site_content_path(site)) }
    end
  end

end
