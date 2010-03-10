class Admin::SaytFiltersController < Admin::AdminController
  active_scaffold :sayt_filter do |config|
    config.columns = [:phrase, :updated_at]
    config.list.sorting = { :phrase => :asc }
  end
end