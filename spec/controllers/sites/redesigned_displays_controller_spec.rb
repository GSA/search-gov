# frozen_string_literal: true

describe Sites::RedesignedDisplaysController do
  before { activate_authlogic }

  describe '#edit' do
    it_behaves_like 'restricted to approved user', :get, :edit, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :edit, params: { site_id: site.id } }

      it { is_expected.to assign_to(:site).with(site) }
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100
  end
end
