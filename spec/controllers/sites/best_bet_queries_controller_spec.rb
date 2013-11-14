require 'spec_helper'

describe Sites::BestBetQueriesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:best_bet) { mock('some kind of best bet') }

      before do
        BoostedContent.stub(:find_by_affiliate_id_and_id).with(site.id, '1234').and_return best_bet
        get :show, id: site.id, module_tag: 'BOOS', model_id: '1234'
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:best_bet).with(best_bet) }
    end
  end

end
