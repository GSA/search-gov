class Admin::SpotlightsController < Admin::AdminController
  active_scaffold :spotlight do |config|
    config.columns = [:updated_at, :title, :is_active, :notes, :spotlight_keywords]
    writables = [:title, :is_active, :notes, :html, :spotlight_keywords]
    config.create.columns = writables
    config.update.columns = writables
    config.list.sorting = { :updated_at => :desc }
  end
end