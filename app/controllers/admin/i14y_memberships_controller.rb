class Admin::I14yMembershipsController < Admin::AdminController
  active_scaffold :i14y_membership do |config|
    config.columns[:affiliate].form_ui = :select
    config.columns[:affiliate].label = 'Site'
    config.columns[:i14y_drawer].form_ui = :select
    config.columns[:i14y_drawer].label = 'I14y Drawer'
  end
end
