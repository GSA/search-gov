class Admin::LogfileBlockedQueriesController < Admin::AdminController
  active_scaffold :logfile_blocked_query do |config|
    config.label = 'Logfile Blocked Queries'
  end
end
