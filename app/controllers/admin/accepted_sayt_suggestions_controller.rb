class Admin::AcceptedSaytSuggestionsController < Admin::AdminController
  active_scaffold :accepted_sayt_suggestion do |config|
    config.actions.exclude :create, :delete, :update
    config.columns = [:phrase, :created_at]
    config.list.sorting = { :phrase => :desc }
  end
end