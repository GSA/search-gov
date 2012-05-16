class Admin::CommonSubstringsController < Admin::AdminController
  active_scaffold :common_substring do |config|
    config.actions.exclude :create, :update
  end
end
