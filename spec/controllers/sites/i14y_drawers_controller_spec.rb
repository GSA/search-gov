require 'spec_helper'

describe Sites::I14yDrawersController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:i14y_drawers) { double('i14y_drawers') }

      before do
        allow(site).to receive_message_chain(:i14y_drawers).and_return(i14y_drawers)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:i14y_drawers).with(i14y_drawers) }
    end
  end

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:i14y_drawer) { double(I14yDrawer, id: 5, handle: 'my_drawer') }
      let(:search_response) { Hashie::Mash.new(results: [{title: 'my title'}]) }
      let(:search_params) do
        {
          handles: 'my_drawer',
          query: 'my query',
          size: 100,
          include: 'title,path,created,changed,updated_at',
          sort_by_date: true,
          language: 'en',
        }
      end

      before do
        allow(site).to receive_message_chain(:i14y_drawers, :find_by_id).and_return i14y_drawer
        expect(I14yCollections).to receive(:search).with(search_params).and_return search_response
        get :show,
            params: {
              site_id: site.id,
              id: 5,
              query: 'my query',
              page: 1
            }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:i14y_documents).with(search_response.results.paginate(per_page: 20, page: 1)) }
    end
  end
end
