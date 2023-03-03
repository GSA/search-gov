require 'spec_helper'

describe Sites::DocumentCollectionsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_behaves_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:document_collections) { double('document collections') }

      before do
        expect(site).to receive(:document_collections).and_return(document_collections)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:document_collections).with(document_collections) }
    end
  end

  describe '#create' do
    it_behaves_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when collection params are valid' do
        let(:document_collection) { mock_model(DocumentCollection, name: 'News') }

        before do
          document_collections = double('document collections')
          allow(site).to receive(:document_collections).and_return(document_collections)
          expect(document_collections).to receive(:build).
            with({ 'name' => 'News',
                   'url_prefixes_attributes' => { '0' => { 'prefix' => 'some.agency.gov/news' } } }).
            and_return(document_collection)
          expect(document_collection).to receive(:save).and_return(true)
          expect(document_collection).to receive(:too_deep_for_bing?).and_return(true)

          email = double(Mail::Message)
          expect(Emailer).to receive(:deep_collection_notification).with(
            current_user, document_collection
          ).
            and_return(email)
          expect(email).to receive(:deliver_now)

          post :create,
               params: {
                 site_id: site.id,
                 document_collection: { name: 'News',
                                        url_prefixes_attributes: {
                                          '0': { prefix: 'some.agency.gov/news',
                                                 invalid_key: 'invalid value' }
                                        },
                                        not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:document_collection).with(document_collection) }
        it { is_expected.to redirect_to site_collections_path(site) }
        it { is_expected.to set_flash.to('You have added News to this site.') }
      end

      context 'when collection params are not valid' do
        let(:document_collection) { mock_model(DocumentCollection) }

        before do
          document_collections = double('document collections')
          allow(site).to receive(:document_collections).and_return(document_collections)
          expect(document_collections).to receive(:build).
            with({ 'name' => 'News',
                   'url_prefixes_attributes' => { '0' => { 'prefix' => '' } } }).
            and_return(document_collection)
          expect(document_collection).to receive(:save).and_return(false)
          allow(document_collection).to receive_message_chain(:url_prefixes, :build)

          post :create,
               params: {
                 site_id: site.id,
                 document_collection: { name: 'News',
                                        url_prefixes_attributes: {
                                          '0': { prefix: '',
                                                 invalid_key: 'invalid value' }
                                        },
                                        not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:document_collection).with(document_collection) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when collection params are not valid' do
        let(:document_collection) { mock_model(DocumentCollection) }

        before do
          document_collections = double('document collections')
          allow(site).to receive(:document_collections).and_return(document_collections)
          expect(document_collections).to receive(:find_by_id).with('100').and_return(document_collection)

          expect(document_collection).to receive(:destroy_and_update_attributes).
            with({ 'name' => 'News',
                   'url_prefixes_attributes' => { '0' => { 'prefix' => '' } } }).
            and_return(false)
          allow(document_collection).to receive_message_chain(:url_prefixes, :build)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                document_collection: { name: 'News',
                                       url_prefixes_attributes: {
                                         '0': { prefix: '',
                                                invalid_key: 'invalid value' }
                                       },
                                       not_allowed_key: 'not allowed value' }
              }
        end

        it { is_expected.to assign_to(:document_collection).with(document_collection) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
