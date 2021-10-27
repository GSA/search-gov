# frozen_string_literal: true

describe 'SystemAlerts', :js do
  let(:url) { '/admin/system_alerts' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'

  context 'when there is an existing alert' do
    before do
      SystemAlert.create(message: 'test alert',
                         start_at: Time.now.utc,
                         end_at: Time.now.utc + 1)
    end

    it_behaves_like 'an ActiveScaffold page',
                    %w[Edit Delete Show],
                    'System Alerts'
  end
end
