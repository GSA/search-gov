class Admin::TagsController < Admin::AdminController
  active_scaffold :tag do |config|
    config.label = 'Site Tags'
    config.columns.exclude :affiliate
    config.list.columns = [:name, :affiliate]
    config.list.sorting = { name: :asc }
  end
end
