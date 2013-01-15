class Admin::LogfileBlockedIpsController < Admin::AdminController
  active_scaffold :logfile_blocked_ip do |config|
    config.label = 'Logfile Blocked IPs'
  end
end
