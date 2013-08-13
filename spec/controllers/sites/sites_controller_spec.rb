require 'spec_helper'

describe Sites::SitesController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :show, id: site.id }

      it { should assign_to(:site).with(site) }
    end

    context 'when logged in as super admin' do
      include_context 'super admin logged in to a site'

      before { get :show, id: site.id }

      it { should assign_to(:site).with(site) }
    end

    context 'when affiliate is looking at dashboard data' do
      include_context 'approved user logged in to a site'

      let(:dashboard) { double('Dashboard') }

      before do
        Dashboard.should_receive(:new).with(site).and_return dashboard
        get :show, id: site.id
      end

      it { should assign_to(:dashboard).with(dashboard) }
    end
  end
end
