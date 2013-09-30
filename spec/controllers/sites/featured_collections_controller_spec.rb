require 'spec_helper'

describe Sites::FeaturedCollectionsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:featured_collections) { mock('featured collections') }

      before do
        site.stub_chain(:featured_collections, :paginate).and_return(featured_collections)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:featured_collections).with(featured_collections) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when featured collection params are valid' do
        let(:featured_collection) { mock_model(FeaturedCollection, title: 'page title') }

        before do
          featured_collections = mock('featured collections')
          site.stub(:featured_collections).and_return(featured_collections)
          featured_collections.should_receive(:build).
              with('title' => 'page title').
              and_return(featured_collection)

          featured_collection.should_receive(:save).and_return(true)

          post :create,
               site_id: site.id,
               featured_collection: { title: 'page title', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:featured_collection).with(featured_collection) }
        it { should redirect_to site_best_bets_graphics_path(site) }
        it { should set_the_flash.to('You have added page title to this site.') }
      end

      context 'when featured collection params are not valid' do
        let(:featured_collection) { mock_model(FeaturedCollection) }

        before do
          featured_collections = mock('featured collections')
          site.stub(:featured_collections).and_return(featured_collections)
          featured_collections.should_receive(:build).
              with('title' => '').
              and_return(featured_collection)

          featured_collection.should_receive(:save).and_return(false)
          featured_collection.stub_chain(:featured_collection_keywords, :build)
          featured_collection.stub_chain(:featured_collection_links, :build)

          post :create,
               site_id: site.id,
               featured_collection: { title: '', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:featured_collection).with(featured_collection) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when featured collection params are not valid' do
        let(:featured_collection) { mock_model(FeaturedCollection) }

        before do
          featured_collections = mock('featured collections')
          site.stub(:featured_collections).and_return(featured_collections)
          featured_collections.should_receive(:find_by_id).with('100').and_return(featured_collection)

          featured_collection.should_receive(:destroy_and_update_attributes).
              with('title' => 'updated title').
              and_return(false)
          featured_collection.stub_chain(:featured_collection_keywords, :build)
          featured_collection.stub_chain(:featured_collection_links, :build)

          put :update,
              site_id: site.id,
              id: 100,
              featured_collection: { title: 'updated title', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:featured_collection).with(featured_collection) }
        it { should render_template(:edit) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        featured_collections = mock('featured collections')
        site.stub(:featured_collections).and_return(featured_collections)

        featured_collection = mock_model(FeaturedCollection, title: 'awesome page')
        featured_collections.should_receive(:find_by_id).with('100').
            and_return(featured_collection)
        featured_collection.should_receive(:destroy)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(site_best_bets_graphics_path(site)) }
      it { should set_the_flash.to(/You have removed awesome page from this site/) }
    end
  end
end
