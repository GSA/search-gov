class Admin::SaytSuggestionsController < Admin::AdminController
  active_scaffold :sayt_suggestion do |config|
    config.columns = [:phrase, :created_at]
    config.list.sorting = { :phrase => :asc }
  end
end