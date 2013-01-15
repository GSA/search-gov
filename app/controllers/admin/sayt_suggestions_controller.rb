class Admin::SaytSuggestionsController < Admin::AdminController
  active_scaffold :sayt_suggestion do |config|
    config.label = 'Type Ahead Suggestions'
    config.list.columns = [:affiliate, :phrase, :is_protected, :created_at, :deleted_at]
    config.columns[:affiliate].label = 'Site'
    config.columns[:affiliate].form_ui = :select
    config.list.sorting = { :phrase => :asc }
  end
end