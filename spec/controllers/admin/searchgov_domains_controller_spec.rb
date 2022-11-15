# frozen_string_literal: true

describe Admin::SearchgovDomainsController do
  fixtures :users, :searchgov_domains
  let(:config) { described_class.active_scaffold_config }

  describe '#update' do
    before do
      activate_authlogic
      UserSession.create(users(:affiliate_admin))
    end

    context 'when configuring Active Scaffold' do
      let(:update_columns) { config.update.columns }

      let(:enable_disable_columns) do
        %i[js_renderer]
      end

      it 'contains the specified columns' do
        expect(update_columns.to_a).to match_array(enable_disable_columns)
      end
    end
  end
end
