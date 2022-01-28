# frozen_string_literal: true

class Admin::DocumentCollectionsController < Admin::AdminController
  active_scaffold :document_collection do |config|
    config.label = 'Collections'
    config.columns = %i[affiliate_id affiliate name too_deep_for_bing? url_prefixes created_at updated_at]
    config.update.columns.exclude :affiliate
    config.columns[:affiliate_id].label = 'Site ID'
    config.columns[:affiliate].form_ui = :select
    config.columns[:affiliate].label = 'Site Handle'
    actions.add :export
    config.list.sorting = [{ affiliate_id: :asc }, { name: :asc }]
  end
end
