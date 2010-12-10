class Admin::CalaisRelatedSearchesController < Admin::AdminController
  active_scaffold :calais_related_search do |config|
    config.list.sorting = { :updated_at => :desc }
    config.columns = [:term, :related_terms, :affiliate, :locale, :gets_refreshed, :updated_at]
    config.columns[:affiliate].form_ui= :select
    config.columns[:gets_refreshed].form_ui= :checkbox
    config.columns[:locale].form_ui= :select
    config.columns[:locale].options = {:options => SUPPORTED_LOCALES.map{|locale| [locale.to_sym, locale]}}
    config.list.per_page = 100
  end
end