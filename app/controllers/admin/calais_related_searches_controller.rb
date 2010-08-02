class Admin::CalaisRelatedSearchesController < Admin::AdminController
  active_scaffold :calais_related_search do |config|
    config.actions.exclude :create, :delete, :update
    config.list.sorting = { :updated_at => :desc }
    config.columns = [:term, :related_terms, :updated_at]
  end
end