require 'spec_helper'

describe Admin::SearchModuleCtrsController do
  fixtures :users
  let(:search_module_ctr) { double(SearchModuleCtr, search_module_ctrs: %w(first second)) }

  before do
    activate_authlogic
    allow(SearchModuleCtr).to receive(:new).with(instance_of(Integer)).and_return search_module_ctr
  end

  describe "GET 'show'" do

    context 'when not logged in' do
      it 'should redirect to the home page' do
        get :show
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before do
        @user = users('affiliate_admin')
        UserSession.create(@user)
        get :show
      end

      it 'should allow the admin to see search module CTRs' do
        expect(response).to be_successful
      end

      it { is_expected.to assign_to(:search_module_ctrs).with(%w(first second)) }

    end
  end
end
