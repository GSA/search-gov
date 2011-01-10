class Admin::PopularImageQueriesController < Admin::AdminController
  active_scaffold :popular_image_query do |config|
    config.list.per_page = 500
    config.list.columns.exclude :updated_at
    config.list.sorting = { :query => :asc }
    config.columns[:query].inplace_edit = :ajax
    config.create.persistent = true
  end
end
