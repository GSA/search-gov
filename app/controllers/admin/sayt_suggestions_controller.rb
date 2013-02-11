class Admin::SaytSuggestionsController < Admin::AdminController
  active_scaffold :sayt_suggestion do |config|
    config.label = 'Type Ahead Suggestions'
    config.list.columns = [:affiliate, :phrase, :is_protected, :is_whitelisted, :created_at, :deleted_at]
    config.columns[:affiliate].label = 'Site'
    config.columns[:affiliate].form_ui = :select
    config.list.sorting = { :phrase => :asc }
    config.actions.exclude :search
    config.actions.add :field_search
    config.field_search.columns = [:phrase, :is_whitelisted]
  end
end