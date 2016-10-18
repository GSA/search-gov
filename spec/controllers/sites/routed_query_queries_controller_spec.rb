require 'spec_helper'

describe Sites::RoutedQueryQueriesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_query) { double('routed query') }

      before do
        RoutedQuery.stub(:find_by_affiliate_id_and_id).with(site.id, '1234').and_return routed_query
        get :show, id: site.id, model_id: '1234'
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:routed_query).with(routed_query) }
    end
  end

end
