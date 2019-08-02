require 'spec_helper'

describe Sites::BoostedContentsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:boosted_contents) { double('boosted contents') }

      before do
        allow(site).to receive_message_chain(:boosted_contents, :substring_match, :paginate, :order).and_return(boosted_contents)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:boosted_contents).with(boosted_contents) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when boosted content params are valid' do
        let(:boosted_content) { mock_model(BoostedContent, title: 'page title') }

        before do
          boosted_contents = double('boosted contents')
          allow(site).to receive(:boosted_contents).and_return(boosted_contents)
          expect(boosted_contents).to receive(:build).
              with('title' => 'page title').
              and_return(boosted_content)

          expect(boosted_content).to receive(:save).and_return(true)

          post :create,
               params: {
                 site_id: site.id,
                 boosted_content: { title: 'page title',
                                    not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:boosted_content).with(boosted_content) }
        it { is_expected.to redirect_to site_best_bets_texts_path(site) }
        it { is_expected.to set_flash.to('You have added page title to this site.') }
      end

      context 'when boosted content params are not valid' do
        let(:boosted_content) { mock_model(BoostedContent) }

        before do
          boosted_contents = double('boosted contents')
          allow(site).to receive(:boosted_contents).and_return(boosted_contents)
          expect(boosted_contents).to receive(:build).
              with('title' => '').
              and_return(boosted_content)

          expect(boosted_content).to receive(:save).and_return(false)
          allow(boosted_content).to receive_message_chain(:boosted_content_keywords, :build)

          post :create,
               params: {
                 site_id: site.id,
                 boosted_content: { title: '', not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:boosted_content).with(boosted_content) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when boosted content params are not valid' do
        let(:boosted_content) { mock_model(BoostedContent) }

        before do
          boosted_contents = double('boosted contents')
          allow(site).to receive(:boosted_contents).and_return(boosted_contents)
          expect(boosted_contents).to receive(:find_by_id).with('100').and_return(boosted_content)

          expect(boosted_content).to receive(:destroy_and_update_attributes).
              with('title' => 'updated title').
              and_return(false)
          allow(boosted_content).to receive_message_chain(:boosted_content_keywords, :build)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                boosted_content: { 
                  title: 'updated title',
                  not_allowed_key: 'not allowed value'
                }
              }
        end

        it { is_expected.to assign_to(:boosted_content).with(boosted_content) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end


  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        boosted_contents = double('boosted contents')
        allow(site).to receive(:boosted_contents).and_return(boosted_contents)

        boosted_content = mock_model(BoostedContent, title: 'awesome page')
        expect(boosted_contents).to receive(:find_by_id).with('100').
            and_return(boosted_content)
        expect(boosted_content).to receive(:destroy)

        delete :destroy, params: { site_id: site.id, id: 100 }
      end

      it { is_expected.to redirect_to(site_best_bets_texts_path(site)) }
      it { is_expected.to set_flash.to(/You have removed awesome page from this site/) }
    end
  end

end
