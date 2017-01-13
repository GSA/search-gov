require 'spec_helper'

describe Sites::RoutedQueriesController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_queries) { double('routed queries') }

      before do
        site.should_receive(:routed_queries).and_return(routed_queries)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:routed_queries).with(routed_queries) }
    end
  end

  describe '#new' do
    it_should_behave_like 'restricted to approved user', :get, :new

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        routed_queries = double('routed queries')
        site.stub(:routed_queries).and_return(routed_queries)
        routed_query = mock_model(RoutedQuery)
        routed_query.stub_chain(:routed_query_keywords, :empty?).and_return(true)
        routed_query.stub_chain(:routed_query_keywords, :build).and_return(mock_model(RoutedQueryKeyword))
        routed_queries.should_receive(:build).and_return(routed_query)

        get :new
      end

      it { should render_template(:new) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

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
        routed_query_keywords.stub(:pluck).with(:keyword).and_return([keyword])
        routed_query_keywords.stub(:empty?).and_return(keyword.blank?)
        routed_query_keywords.stub(:build).and_return(mock_model(RoutedQueryKeyword))
        routed_query.stub(:routed_query_keywords).and_return(routed_query_keywords)
        site.stub(:routed_queries).and_return(routed_queries)
        routed_queries.should_receive(:build).with(attrs).and_return(routed_query)
        routed_query.should_receive(:save).and_return(!keyword.blank?)

        post :create,
             site_id: site.id,
             routed_query: attrs.merge('not_allowed_key' => 'not allowed value')
      end

      context 'when routed query params are valid' do
        let(:keyword) { 'free money' }

        it { should assign_to(:routed_query).with(routed_query) }
        it { should redirect_to site_routed_queries_path(site) }
        it { should set_flash.to("You have added query routing for the following search term: '#{keyword}'") }
      end

      context 'when routed query params are not valid' do
        let(:keyword) { '' }

        it { should assign_to(:routed_query).with(routed_query) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#edit' do
    it_should_behave_like 'restricted to approved user', :get, :edit

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_query) { mock_model(RoutedQuery, description: 'Free money', url: 'https://www.usa.gov/free-money') }
      let(:keyword) { 'free money' }

      before do
        routed_queries = double('routed queries')
        site.stub(:routed_queries).and_return(routed_queries)
        routed_queries.should_receive(:find_by_id).with('100').and_return(routed_query)

        routed_query.stub_chain(:routed_query_keywords, :pluck).with(:keyword).and_return([keyword])
        routed_query.stub_chain(:routed_query_keywords, :empty?).and_return(keyword.blank?)

        get :edit,
            site_id: site.id,
            id: 100
      end

      context 'when routed query params are valid' do
        it { should assign_to(:routed_query).with(routed_query) }
        it { should render_template(:edit) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

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
        site.stub(:routed_queries).and_return(routed_queries)
        routed_queries.should_receive(:find_by_id).with('100').and_return(routed_query)

        routed_query.stub_chain(:routed_query_keywords, :pluck).with(:keyword).and_return([keyword])
        routed_query.stub_chain(:routed_query_keywords, :empty?).and_return(keyword.blank?)

        routed_query.should_receive(:destroy_and_update_attributes)
          .with(attrs).and_return(dau_result)
        routed_query.stub_chain(:routed_query_keywords, :build).and_return(mock_model(RoutedQueryKeyword))

        put :update,
            site_id: site.id,
            id: 100,
            routed_query: attrs
      end

      context 'when routed query params are valid' do
        let(:keyword) { 'free money' }
        it { should assign_to(:routed_query).with(routed_query) }
        it { should redirect_to site_routed_queries_path(site) }
        it { should set_flash.to("You have updated query routing for the following search term: '#{keyword}'") }
      end

      context 'when routed query params are not valid' do
        let(:keyword) { '' }
        it { should assign_to(:routed_query).with(routed_query) }
        it { should render_template(:edit) }
      end
    end
  end

  describe '#delete' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:routed_query) { mock_model(RoutedQuery) }
      let(:keyword) { 'free money' }

      before do
        routed_queries = double('routed queries')
        site.stub(:routed_queries).and_return(routed_queries)
        routed_query.stub_chain(:routed_query_keywords, :pluck).with(:keyword).and_return([keyword])
        routed_queries.should_receive(:find_by_id).with('100').and_return(routed_query)
        routed_query.should_receive(:destroy)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should assign_to(:routed_query).with(routed_query) }
      it { should redirect_to site_routed_queries_path(site) }
      it { should set_flash.to("You have removed query routing for the following search term: '#{keyword}'") }
    end
  end

  describe '#new_routed_query_keyword' do
    it_should_behave_like 'restricted to approved user', :get, :new_routed_query_keyword

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        get :new_routed_query_keyword, site_id: site.id, index: 0, format: :js
      end

      it { should render_template(:new_routed_query_keyword) }
    end
  end
end
