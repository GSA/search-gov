class Admin::LogfileBlockedRegexpsController < Admin::AdminController
  active_scaffold :logfile_blocked_regexp do |config|
    config.label = 'Logfile Blocked Regexps'
  end
end
