# frozen_string_literal: true

describe Admin::SearchgovDomainsController do
  fixtures :users, :searchgov_domains, :searchgov_urls

  let(:basic_domain) { searchgov_domains(:basic_domain) }

  before do
    activate_authlogic
    UserSession.create(users(:affiliate_admin))
  end

  describe 'after_create_save' do
    it 'sets flash[:info] message correctly' do
      expect { post :create, params: { record: { domain: 'www.usa.gov' } } }.
        to change { SearchgovDomain.count }.by(1)

      expect(flash[:info]).to include(SearchgovDomain.last.domain.to_s)
    end
  end

  describe '#update' do
    it 'contains the specified columns' do
      expect(described_class.active_scaffold_config.update.columns.to_a).to include(:js_renderer)
    end
  end

  describe '#confirm_delete' do
    it 'renders the delete_domain template' do
      get :confirm_delete, params: { id: basic_domain.id }

      expect(response).to render_template(:delete_domain)
    end
  end

  describe '#delete_domain' do
    context 'with correct confirmation text' do
      it 'enqueues the deletion job and redirects to index' do
        delete :delete_domain, params: { id: basic_domain.id, confirmation: 'DESTROY DOMAIN' }

        expect(response).to redirect_to(action: :index)
        expect(flash[:success]).to eq(I18n.t('flash_messages.searchgov_domains.delete.success', domain: basic_domain.domain))
        expect(SearchgovDomainDestroyerJob).to have_been_enqueued.with(basic_domain)
      end
    end

    context 'with incorrect confirmation text' do
      it 'does not enqueue the deletion job and redirects to show' do
        delete :delete_domain, params: { id: basic_domain.id, confirmation: 'INCORRECT TEXT' }

        expect(response).to redirect_to(action: :show, id: basic_domain.id)
        expect(flash[:error]).to eq('Incorrect confirmation text. Deletion aborted.')
        expect(SearchgovDomainDestroyerJob).not_to have_been_enqueued
      end
    end
  end
end
