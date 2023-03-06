require 'spec_helper'

describe Sites::FeaturedCollectionsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_behaves_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:featured_collections) { double('featured collections') }

      before do
        allow(site).to receive_message_chain(:featured_collections, :substring_match, :paginate, :order).and_return(featured_collections)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:featured_collections).with(featured_collections) }
    end
  end

  describe '#create' do
    it_behaves_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when featured collection params are valid' do
        let(:featured_collection) { mock_model(FeaturedCollection, title: 'page title') }

        before do
          featured_collections = double('featured collections')
          allow(site).to receive(:featured_collections).and_return(featured_collections)
          expect(featured_collections).to receive(:build).
            with({ 'title' => 'page title' }).
            and_return(featured_collection)

          expect(featured_collection).to receive(:save).and_return(true)

          post :create,
               params: {
                 site_id: site.id,
                 featured_collection: { title: 'page title',
                                        not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:featured_collection).with(featured_collection) }
        it { is_expected.to redirect_to site_best_bets_graphics_path(site) }
        it { is_expected.to set_flash.to('You have added page title to this site.') }
      end

      context 'when featured collection params are not valid' do
        let(:featured_collection) { mock_model(FeaturedCollection) }

        before do
          featured_collections = double('featured collections')
          allow(site).to receive(:featured_collections).and_return(featured_collections)
          expect(featured_collections).to receive(:build).
            with({ 'title' => '' }).
            and_return(featured_collection)

          expect(featured_collection).to receive(:save).and_return(false)
          allow(featured_collection).to receive_message_chain(:featured_collection_keywords, :build)
          allow(featured_collection).to receive_message_chain(:featured_collection_links, :build)

          post :create,
               params: {
                 site_id: site.id,
                 featured_collection: { title: '', not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:featured_collection).with(featured_collection) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when featured collection params are not valid' do
        let(:featured_collection) { mock_model(FeaturedCollection) }

        before do
          featured_collections = double('featured collections')
          allow(site).to receive(:featured_collections).and_return(featured_collections)
          expect(featured_collections).to receive(:find_by_id).with('100').and_return(featured_collection)

          expect(featured_collection).to receive(:destroy_and_update_attributes).
            with({ 'title' => 'updated title' }).
            and_return(false)
          allow(featured_collection).to receive_message_chain(:featured_collection_keywords, :build)
          allow(featured_collection).to receive_message_chain(:featured_collection_links, :build)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                featured_collection: { title: 'updated title',
                                       not_allowed_key: 'not allowed value' }
              }
        end

        it { is_expected.to assign_to(:featured_collection).with(featured_collection) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end

  describe '#destroy' do
    it_behaves_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        featured_collections = double('featured collections')
        allow(site).to receive(:featured_collections).and_return(featured_collections)

        featured_collection = mock_model(FeaturedCollection, title: 'awesome page')
        expect(featured_collections).to receive(:find_by_id).with('100').
          and_return(featured_collection)
        expect(featured_collection).to receive(:destroy)

        delete :destroy, params: { site_id: site.id, id: 100 }
      end

      it { is_expected.to redirect_to(site_best_bets_graphics_path(site)) }
      it { is_expected.to set_flash.to(/You have removed awesome page from this site/) }
    end
  end
end
