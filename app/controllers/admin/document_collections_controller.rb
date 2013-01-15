class Admin::DocumentCollectionsController < Admin::AdminController
  active_scaffold :document_collection do |config|
    config.label = 'Collections'
    config.columns.exclude :navigation
    config.update.columns.exclude :affiliate
    config.columns[:affiliate].form_ui = :select
    config.columns[:affiliate].label = 'Site'
    config.columns[:scope_keywords].description = 'Enter one or more keywords to limit searches by, separated by commas.'
  end
end
