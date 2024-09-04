require 'spec_helper'

describe Admin::QueryCtrsController do
  fixtures :users, :search_modules, :affiliates
  let(:query_ctr) { double(QueryCtr, query_ctrs: %w(first second)) }
  let(:search_module) { search_modules(:boos) }
  let(:site) { affiliates(:usagov_affiliate) }

  before do
    activate_authlogic
    allow(QueryCtr).to receive(:new).with(instance_of(Integer), 'BOOS', 'usagov').and_return query_ctr
  end

  describe "GET 'show'" do

    context 'when not logged in' do
      it 'should redirect to the home page' do
        get :show, params: { module_tag: 'BOOS', site_name: 'usagov' }
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before do
        @user = users('affiliate_admin')
        UserSession.create(@user)
        get :show, params: { module_tag: 'BOOS', site_name: 'usagov' }
      end

      it 'should allow the admin to see query CTRs for some search module on a given site' do
        expect(response).to be_successful
      end

      it { is_expected.to assign_to(:query_ctrs).with(%w(first second)) }
      it { is_expected.to assign_to(:search_module).with(search_module) }
      it { is_expected.to assign_to(:site).with(site) }

    end
  end
end
