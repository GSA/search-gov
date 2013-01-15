class Admin::LogfileBlockedUserAgentsController < Admin::AdminController
  active_scaffold :logfile_blocked_user_agent do |config|
    config.label = 'Logfile Blocked User Agents'
  end
end
