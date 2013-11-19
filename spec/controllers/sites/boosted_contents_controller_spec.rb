require 'spec_helper'

describe Sites::BoostedContentsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:boosted_contents) { mock('boosted contents') }

      before do
        site.stub_chain(:boosted_contents, :substring_match, :paginate).and_return(boosted_contents)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:boosted_contents).with(boosted_contents) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when boosted content params are valid' do
        let(:boosted_content) { mock_model(BoostedContent, title: 'page title') }

        before do
          boosted_contents = mock('boosted contents')
          site.stub(:boosted_contents).and_return(boosted_contents)
          boosted_contents.should_receive(:build).
              with('title' => 'page title').
              and_return(boosted_content)

          boosted_content.should_receive(:save).and_return(true)
          Sunspot.should_receive(:index).with(boosted_content)

          post :create,
               site_id: site.id,
               boosted_content: { title: 'page title', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:boosted_content).with(boosted_content) }
        it { should redirect_to site_best_bets_texts_path(site) }
        it { should set_the_flash.to('You have added page title to this site.') }
      end

      context 'when boosted content params are not valid' do
        let(:boosted_content) { mock_model(BoostedContent) }

        before do
          boosted_contents = mock('boosted contents')
          site.stub(:boosted_contents).and_return(boosted_contents)
          boosted_contents.should_receive(:build).
              with('title' => '').
              and_return(boosted_content)

          boosted_content.should_receive(:save).and_return(false)
          boosted_content.stub_chain(:boosted_content_keywords, :build)

          post :create,
               site_id: site.id,
               boosted_content: { title: '', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:boosted_content).with(boosted_content) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when boosted content params are not valid' do
        let(:boosted_content) { mock_model(BoostedContent) }

        before do
          boosted_contents = mock('boosted contents')
          site.stub(:boosted_contents).and_return(boosted_contents)
          boosted_contents.should_receive(:find_by_id).with('100').and_return(boosted_content)

          boosted_content.should_receive(:destroy_and_update_attributes).
              with('title' => 'updated title').
              and_return(false)
          boosted_content.stub_chain(:boosted_content_keywords, :build)

          put :update,
              site_id: site.id,
              id: 100,
              boosted_content: { title: 'updated title', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:boosted_content).with(boosted_content) }
        it { should render_template(:edit) }
      end
    end
  end


  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        boosted_contents = mock('boosted contents')
        site.stub(:boosted_contents).and_return(boosted_contents)

        boosted_content = mock_model(BoostedContent, title: 'awesome page')
        boosted_contents.should_receive(:find_by_id).with('100').
            and_return(boosted_content)
        boosted_content.should_receive(:destroy)
        boosted_content.should_receive(:solr_remove_from_index)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(site_best_bets_texts_path(site)) }
      it { should set_the_flash.to(/You have removed awesome page from this site/) }
    end
  end

  describe '#bulk_upload' do
    it_should_behave_like 'restricted to approved user', :post, :update

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when best bets text data file is not valid' do
        before do
          data_file = mock('best bets text data file', to_s: 'file content')

          BoostedContent.should_receive(:bulk_upload).
              with(site, 'file content').
              and_return({ error_message: 'some error message' })

          post :bulk_upload, best_bets_text_data_file: data_file
        end

        it { should set_the_flash.to('some error message').now }
        it { should render_template(:new_bulk_upload) }
      end
    end
  end
end
