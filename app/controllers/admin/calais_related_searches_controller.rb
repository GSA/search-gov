class Admin::CalaisRelatedSearchesController < Admin::AdminController
  active_scaffold :calais_related_search do |config|
    config.list.sorting = { :updated_at => :desc }
    config.columns = [:term, :related_terms, :locale, :updated_at]
    config.columns[:locale].form_ui= :select
    config.columns[:locale].options = {:options => CalaisRelatedSearch::SUPPORTED_LOCALES.map(&:to_sym)}        
    config.list.per_page = 100
  end
end