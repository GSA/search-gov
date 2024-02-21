# frozen_string_literal: true

describe Admin::SearchgovDomainsController do
  fixtures :users, :searchgov_domains, :searchgov_urls

  let(:config) { described_class.active_scaffold_config }
  let(:basic_domain) { searchgov_domains(:basic_domain) }

  before do
    activate_authlogic
    UserSession.create(users(:affiliate_admin))
  end

  describe '#update' do
    context 'when configuring Active Scaffold' do
      let(:update_columns) { config.update.columns }
      let(:enable_disable_columns) { %i[js_renderer] }

      it 'contains the specified columns' do
        expect(update_columns.to_a).to match_array(enable_disable_columns)
      end
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
        expect { post :delete_domain, params: { id: basic_domain.id, confirmation: 'DESTROY DOMAIN' } }
          .to have_enqueued_job(SearchgovDomainDestroyerJob).with(basic_domain)

        expect(flash[:success]).to eq("Deletion has been enqueued for #{basic_domain.domain}")
        expect(response).to redirect_to(action: :index)
      end
    end

    context 'with incorrect confirmation text' do
      it 'does not enqueue the deletion job and redirects to show' do
        expect { post :delete_domain, params: { id: basic_domain.id, confirmation: 'INCORRECT TEXT' } }
          .not_to have_enqueued_job(SearchgovDomainDestroyerJob)

        expect(flash[:error]).to eq('Incorrect confirmation text. Deletion aborted.')
        expect(response).to redirect_to(action: :show, id: basic_domain.id)
      end
    end
  end
end
