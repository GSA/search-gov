class Admin::LogfileWhitelistedClassCsController < Admin::AdminController
  active_scaffold :logfile_whitelisted_class_c do |config|
    config.label = 'Logfile Whitelisted Class Cs'
  end
end
