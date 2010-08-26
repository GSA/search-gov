class Admin::CalaisRelatedSearchesController < Admin::AdminController
  active_scaffold :calais_related_search do |config|
    config.list.sorting = { :updated_at => :desc }
    config.columns = [:term, :related_terms, :updated_at]
    config.list.per_page = 100
  end
end