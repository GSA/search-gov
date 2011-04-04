class Admin::SaytFiltersController < Admin::AdminController
  active_scaffold :sayt_filter do |config|
    config.columns = [:phrase, :always_filtered, :filter_only_exact_phrase, :updated_at]
    config.list.sorting = { :phrase => :asc }
    config.list.per_page = 100
  end
end
