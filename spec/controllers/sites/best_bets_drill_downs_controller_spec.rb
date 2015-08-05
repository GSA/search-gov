require 'spec_helper'

describe Sites::BestBetsDrillDownsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:best_bets_drill_down) { mock('boosted contents') }

      before do
        SearchModuleDrillDown.stub(:new).with(site, 'BOOS').and_return best_bets_drill_down
        get :show, id: site.id, module_tag: 'BOOS'
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:best_bets_drill_down).with(best_bets_drill_down) }
    end
  end

end
