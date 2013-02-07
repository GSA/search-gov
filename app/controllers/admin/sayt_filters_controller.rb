class Admin::SaytFiltersController < Admin::AdminController
  active_scaffold :sayt_filter do |config|
    config.label = 'Type Ahead Filters'
    config.columns = [:phrase, :always_filtered, :filter_only_exact_phrase, :is_regex, :accept, :updated_at]
    config.list.sorting = { :phrase => :asc }
  end
end
