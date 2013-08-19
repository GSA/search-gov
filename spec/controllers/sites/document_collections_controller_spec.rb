require 'spec_helper'

describe Sites::DocumentCollectionsController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:document_collections) { double('document collections') }

      before do
        site.should_receive(:document_collections).and_return(document_collections)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:document_collections).with(document_collections) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when collection params are valid' do
        let(:document_collection) { mock_model(DocumentCollection, name: 'News') }

        before do
          document_collections = double('document collections')
          site.stub(:document_collections).and_return(document_collections)
          document_collections.should_receive(:build).
              with('name' => 'News',
                   'url_prefixes_attributes' => { '0' =>{ 'prefix' => 'some.agency.gov/news' } }).
              and_return(document_collection)
          document_collection.should_receive(:save).and_return(true)
          document_collection.should_receive(:too_deep_for_bing?).and_return(true)

          email = double(Mail::Message)
          Emailer.should_receive(:deep_collection_notification).with(
              current_user, document_collection).
              and_return(email)
          email.should_receive(:deliver)

          post :create,
               site_id: site.id,
               document_collection: { name: 'News',
                                      url_prefixes_attributes: { '0' => { prefix: 'some.agency.gov/news',
                                                                          invalid_key: 'invalid value'} },
                                      not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:document_collection).with(document_collection) }
        it { should redirect_to site_collections_path(site) }
        it { should set_the_flash.to('You have added News to this site.') }
      end

      context 'when collection params are not valid' do
        let(:document_collection) { mock_model(DocumentCollection) }

        before do
          document_collections = double('document collections')
          site.stub(:document_collections).and_return(document_collections)
          document_collections.should_receive(:build).
              with('name' => 'News',
                   'url_prefixes_attributes' => { '0' =>{ 'prefix' => '' } }).
              and_return(document_collection)
          document_collection.should_receive(:save).and_return(false)
          document_collection.stub_chain(:url_prefixes, :build)

          post :create,
               site_id: site.id,
               document_collection: { name: 'News',
                                      url_prefixes_attributes: { '0' => { prefix: '',
                                                                          invalid_key: 'invalid value'} },
                                      not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:document_collection).with(document_collection) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when collection params are not valid' do
        let(:document_collection) { mock_model(DocumentCollection) }

        before do
          document_collections = double('document collections')
          site.stub(:document_collections).and_return(document_collections)
          document_collections.should_receive(:find_by_id).with('100').and_return(document_collection)

          document_collection.should_receive(:destroy_and_update_attributes).
              with('name' => 'News',
                   'url_prefixes_attributes' => { '0' =>{ 'prefix' => '' } }).
              and_return(false)
          document_collection.stub_chain(:url_prefixes, :build)

          put :update,
               site_id: site.id,
               id: 100,
               document_collection: { name: 'News',
                                      url_prefixes_attributes: { '0' => { prefix: '',
                                                                          invalid_key: 'invalid value'} },
                                      not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:document_collection).with(document_collection) }
        it { should render_template(:edit) }
      end
    end
  end
end
