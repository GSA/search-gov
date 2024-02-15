# frozen_string_literal: true

describe Admin::OdieUrlSourceUpdateController do
  let(:user) { users('affiliate_admin') }

  before { activate_authlogic }

  describe "GET 'index'" do
    context 'when not logged in' do
      before { get :index }

      it { is_expected.to redirect_to login_path }
    end

    context 'when logged in as an admin' do
      before do
        UserSession.create(user)
        get :index
      end

      its(:response) { is_expected.to be_successful }
    end
  end

  describe '#affiliate_lookup' do
    context 'when logged in as an admin' do
      before { UserSession.create(user) }

      context 'when affiliate exists' do
        let(:affiliate) { affiliates('blended_affiliate') }

        before { get :affiliate_lookup, params: { affiliate_name: affiliate.name } }

        its(:response) { is_expected.to render_template('index') }
      end

      context 'when affiliate does not exist' do
        before { get :affiliate_lookup, params: { affiliate_name: 'nonsense' } }

        it { is_expected.to redirect_to '/admin/odie_url_source_update' }

        it { is_expected.to set_flash[:error].to(/No affiliate matches the handle nonsense/) }
      end
    end
  end

  describe '#update_job' do
    context 'when logged in as an admin' do
      let(:affiliate) { affiliates('blended_affiliate') }

      before do
        UserSession.create(user)
        post :update_job, params: { affiliate_id: affiliate.id }
      end

      its(:response) { is_expected.to render_template('index') }

      it { is_expected.to set_flash[:success].to("ODIE URL Source Update job enqueued for affiliate #{affiliate.name}.") }
    end
  end
end
