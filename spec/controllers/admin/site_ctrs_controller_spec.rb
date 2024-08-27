require 'spec_helper'

describe Admin::SiteCtrsController do
  fixtures :users, :search_modules
  let(:site_ctr) { double(SiteCtr, site_ctrs: %w(first second)) }
  let(:search_module) { search_modules(:boos) }

  before do
    activate_authlogic
    allow(SiteCtr).to receive(:new).with(instance_of(Integer), 'BOOS').and_return site_ctr
  end

  describe "GET 'show'" do

    context 'when not logged in' do
      it 'should redirect to the home page' do
        get :show, params: { module_tag: 'BOOS' }
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before do
        @user = users('affiliate_admin')
        UserSession.create(@user)
        get :show, params: { module_tag: 'BOOS' }
      end

      it 'should allow the admin to see site CTRs for some search module' do
        expect(response).to be_successful
      end

      it { is_expected.to assign_to(:site_ctrs).with(%w(first second)) }
      it { is_expected.to assign_to(:search_module).with(search_module) }

    end
  end
end
