class Admin::SearchModulesController < Admin::AdminController
  active_scaffold :search_module do |config|
    config.label = 'Modules'
  end
end
