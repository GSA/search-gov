class Admin::LogfileBlockedClassCsController < Admin::AdminController
  active_scaffold :logfile_blocked_class_c do |config|
    config.label = 'Logfile Blocked Class Cs'
  end
end
