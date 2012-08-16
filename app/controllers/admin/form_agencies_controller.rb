class Admin::FormAgenciesController < Admin::AdminController
  active_scaffold :form_agency do |config|
    config.label = 'Form Agencies'
    config.actions = [:list, :search, :update, :delete, :show]
    config.columns.exclude :affiliates, :forms
    config.update.columns.exclude :name, :locale
  end
end