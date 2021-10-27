# frozen_string_literal: true

describe 'AnalyticsAlerts', :js do
  let(:url) { '/admin/watchers' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'a Search'

  context 'when there is an existing alert' do
    before do
      Watcher.create(type: 'NoResultsWatcher',
                     user: User.first,
                     affiliate: Affiliate.first,
                     name: 'test watcher',
                     check_interval: '4h',
                     throttle_period: '1d',
                     time_window: '1d',
                     conditions: { distinct_user_total: '2' })
    end

    it_behaves_like 'an ActiveScaffold page',
                    %w[Show],
                    'Analytics Alerts'
  end
end
