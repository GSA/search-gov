class Admin::SaytSuggestionsController < Admin::AdminController
  active_scaffold :sayt_suggestion do |config|
    config.list.columns = [:phrase, :created_at]
    config.columns[:affiliate].form_ui = :select
    config.list.sorting = { :phrase => :asc }
  end
end