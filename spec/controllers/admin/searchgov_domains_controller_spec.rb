# frozen_string_literal: true

describe Admin::SearchgovDomainsController do
  fixtures :users, :searchgov_domains

  let(:config) { described_class.active_scaffold_config }

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

  describe 'stop_indexing' do
    let(:domain) { searchgov_domains(:agency_gov) }
 
    it 'calls stop_indexing! on domain' do
      allow(SearchDomain).to receive(:find).and_return(domain)

      post stop_indexing_admin_searchgov_domain_path(domain)

      expect(domain).to receive(:stop_indexing!)
    end
  end
end
