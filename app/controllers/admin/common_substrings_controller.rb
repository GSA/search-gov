class Admin::CommonSubstringsController < Admin::AdminController
  active_scaffold :common_substring do |config|
    config.label = 'Common Website Substrings'
    config.actions.exclude :create, :update
  end
end
