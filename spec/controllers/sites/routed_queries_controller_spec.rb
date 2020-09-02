require 'spec_helper'

describe Sites::RoutedQueriesController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_queries) { double('routed queries') }

      before do
        expect(site).to receive(:routed_queries).and_return(routed_queries)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:routed_queries).with(routed_queries) }
    end
  end

  describe '#new' do
    it_should_behave_like 'restricted to approved user', :get, :new, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        routed_queries = double('routed queries')
        allow(site).to receive(:routed_queries).and_return(routed_queries)
        routed_query = mock_model(RoutedQuery)
        allow(routed_query).to receive_message_chain(:routed_query_keywords, :empty?).and_return(true)
        allow(routed_query).to receive_message_chain(:routed_query_keywords, :build).and_return(mock_model(RoutedQueryKeyword))
        expect(routed_queries).to receive(:build).and_return(routed_query)

        get :new, params: { site_id: site.id }
      end

      it { is_expected.to render_template(:new) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:description) { 'My Routed Query' }
      let(:url) { 'https://www.usa.gov/free-money' }
      let(:routed_query) { mock_model(RoutedQuery, description: description, url: url) }
      let(:attrs) do
        {
          'description' => description,
          'url' => url,
          'routed_query_keywords_attributes' => { '0' => { 'keyword' => keyword } }
        }
      end

      before do
        routed_queries = double('routed queries')
        routed_query_keywords = double('routed query keywords')
        allow(routed_query_keywords).to receive(:pluck).with(:keyword).and_return([keyword])
        allow(routed_query_keywords).to receive(:empty?).and_return(keyword.blank?)
        allow(routed_query_keywords).to receive(:build).and_return(mock_model(RoutedQueryKeyword))
        allow(routed_query).to receive(:routed_query_keywords).and_return(routed_query_keywords)
        allow(site).to receive(:routed_queries).and_return(routed_queries)
        expect(routed_queries).to receive(:build).with(attrs).and_return(routed_query)
        expect(routed_query).to receive(:save).and_return(!keyword.blank?)

        post :create,
             params: {
               site_id: site.id,
               routed_query: attrs.merge('not_allowed_key': 'not allowed value')
             }
      end

      context 'when routed query params are valid' do
        let(:keyword) { 'free money' }

        it { is_expected.to assign_to(:routed_query).with(routed_query) }
        it { is_expected.to redirect_to site_routed_queries_path(site) }
        it { is_expected.to set_flash.to("You have added query routing for the following search term: '#{keyword}'") }
      end

      context 'when routed query params are not valid' do
        let(:keyword) { '' }

        it { is_expected.to assign_to(:routed_query).with(routed_query) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#edit' do
    it_should_behave_like 'restricted to approved user', :get, :edit, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_query) { mock_model(RoutedQuery, description: 'Free money', url: 'https://www.usa.gov/free-money') }
      let(:keyword) { 'free money' }

      before do
        routed_queries = double('routed queries')
        allow(site).to receive(:routed_queries).and_return(routed_queries)
        expect(routed_queries).to receive(:find_by_id).with('100').and_return(routed_query)

        allow(routed_query).to receive_message_chain(:routed_query_keywords, :pluck).with(:keyword).and_return([keyword])
        allow(routed_query).to receive_message_chain(:routed_query_keywords, :empty?).and_return(keyword.blank?)

        get :edit,
            params: {
              site_id: site.id,
              id: 100
            }
      end

      context 'when routed query params are valid' do
        it { is_expected.to assign_to(:routed_query).with(routed_query) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_query) { mock_model(RoutedQuery) }
      let(:attrs) do
        {
          'description' => 'My Routed Query',
          'url' => 'https://www.usa.gov/free-money',
          'routed_query_keywords_attributes' => { '0' => { 'keyword' => keyword } }
        }
      end
      let(:dau_result) { !keyword.blank? }

      before do
        routed_queries = double('routed queries')
        allow(site).to receive(:routed_queries).and_return(routed_queries)
        expect(routed_queries).to receive(:find_by_id).with('100').and_return(routed_query)

        allow(routed_query).to receive_message_chain(:routed_query_keywords, :pluck).with(:keyword).and_return([keyword])
        allow(routed_query).to receive_message_chain(:routed_query_keywords, :empty?).and_return(keyword.blank?)

        expect(routed_query).to receive(:destroy_and_update_attributes)
          .with(attrs).and_return(dau_result)
        allow(routed_query).to receive_message_chain(:routed_query_keywords, :build).and_return(mock_model(RoutedQueryKeyword))

        put :update,
            params: {
              site_id: site.id,
              id: 100,
              routed_query: attrs
            }
      end

      context 'when routed query params are valid' do
        let(:keyword) { 'free money' }
        it { is_expected.to assign_to(:routed_query).with(routed_query) }
        it { is_expected.to redirect_to site_routed_queries_path(site) }
        it { is_expected.to set_flash.to("You have updated query routing for the following search term: '#{keyword}'") }
      end

      context 'when routed query params are not valid' do
        let(:keyword) { '' }
        it { is_expected.to assign_to(:routed_query).with(routed_query) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end

  describe '#delete' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_query) { mock_model(RoutedQuery) }
      let(:keyword) { 'free money' }

      before do
        routed_queries = double('routed queries')
        allow(site).to receive(:routed_queries).and_return(routed_queries)
        allow(routed_query).to receive_message_chain(:routed_query_keywords, :pluck).with(:keyword).and_return([keyword])
        expect(routed_queries).to receive(:find_by_id).with('100').and_return(routed_query)
        expect(routed_query).to receive(:destroy)

        delete :destroy,
               params: {
                 site_id: site.id,
                 id: 100
               }
      end

      it { is_expected.to assign_to(:routed_query).with(routed_query) }
      it { is_expected.to redirect_to site_routed_queries_path(site) }
      it { is_expected.to set_flash.to("You have removed query routing for the following search term: '#{keyword}'") }
    end
  end

  describe '#new_routed_query_keyword' do
    it_should_behave_like 'restricted to approved user', :get, :new_routed_query_keyword, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        get :new_routed_query_keyword, params: {
          site_id: site.id,
          index: 0
        }, xhr: true, format: :js
      end

      it { is_expected.to render_template(:new_routed_query_keyword) }
    end
  end
end
