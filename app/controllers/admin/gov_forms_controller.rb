class Admin::GovFormsController < Admin::AdminController
  active_scaffold :gov_form do |config|
    config.label = 'Government Forms'
  end
end
