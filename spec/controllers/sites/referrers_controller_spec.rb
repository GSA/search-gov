require 'spec_helper'

describe Sites::ReferrersController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }
  let(:rtu_referrers_request) { double(RtuReferrersRequest) }

  describe '#new' do
    it_should_behave_like 'restricted to approved user', :get, :new

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        RtuReferrersRequest.should_receive(:new).with(site: site, filter_bots: current_user.sees_filtered_totals?).and_return rtu_referrers_request
        rtu_referrers_request.should_receive(:save)
        get :new, id: site.id
      end

      it { should assign_to(:referrers_request).with(rtu_referrers_request) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :get, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'
      it_should_behave_like 'an analytics controller'

      before do
        params = { "start_date"=>"05/01/2014", "end_date"=>"05/26/2014", "site"=> site, "filter_bots"=> current_user.sees_filtered_totals?}
        RtuReferrersRequest.should_receive(:new).with(params).and_return rtu_referrers_request
        rtu_referrers_request.should_receive(:save)
        rtu_referrers_request.should_receive(:start_date).and_return "05/01/2014".to_date
        rtu_referrers_request.should_receive(:end_date).and_return "05/26/2014".to_date
        post :create, id: site.id, rtu_referrers_request: { start_date: "05/01/2014", end_date: "05/26/2014" }
      end

      it { should assign_to(:referrers_request).with(rtu_referrers_request) }
      it { should render_template(:new) }
    end
  end
end
