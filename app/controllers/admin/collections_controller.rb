class Admin::CollectionsController < Admin::AdminController
  active_scaffold :document_collection do |config|
    config.columns[:affiliate].form_ui = :select
  end
end
