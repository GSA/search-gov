# frozen_string_literal: true

describe Sites::LinksController do
  before { activate_authlogic }

  describe '#new' do
    it_behaves_like 'restricted to approved user', :get, :new, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        get :new, params: { site_id: site.id, positions: 0, type: 'SecondaryHeaderLink' }, xhr: true, format: :js
      end

      it { is_expected.to render_template(:new) }
    end
  end
end
