class Admin::NewsItemsController < Admin::AdminController
  active_scaffold :news_item do |config|
    config.label = 'RSS News Items'
    config.columns.exclude :properties
    config.list.sorting = { created_at: :desc }
  end
end
