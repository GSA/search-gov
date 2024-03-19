# frozen_string_literal: true

describe Admin::SearchgovDomainsController do
  fixtures :users, :searchgov_domains

  before do
    activate_authlogic

    UserSession.create(users(:affiliate_admin))
  end

  describe '#update' do
    let(:config) { described_class.active_scaffold_config }

    context 'when configuring Active Scaffold' do
      let(:update_columns) { config.update.columns }
      let(:enable_disable_columns) { %i[js_renderer] }

      it 'contains the specified columns' do
        expect(update_columns.to_a).to match_array(enable_disable_columns)
      end
    end
  end

  # rubocop:disable RSpec/AnyInstance
  describe 'stop_indexing' do
    let(:domain) { searchgov_domains(:agency_gov) }

    it 'calls stop_indexing! on domain' do
      expect_any_instance_of(SearchgovDomain).to receive(:stop_indexing!)

      post :stop_indexing, params: { id: domain.id }
    end
  end
  # rubocop:enable RSpec/AnyInstance
end
