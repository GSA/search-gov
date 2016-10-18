require 'spec_helper'

describe Sites::RoutedQueriesDrillDownsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_queries_drill_down) { double('routed query drill down') }

      before do
        SearchModuleDrillDown.stub(:new).with(site, 'QRTD').and_return routed_queries_drill_down
        get :show, id: site.id, module_tag: 'QRTD'
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:routed_queries_drill_down).with(routed_queries_drill_down) }
    end
  end

end
