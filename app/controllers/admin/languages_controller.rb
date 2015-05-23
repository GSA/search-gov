class Admin::LanguagesController < Admin::AdminController
  active_scaffold :language do |config|
    config.update.columns.exclude :affiliates
    config.create.columns.exclude :affiliates
    config.list.sorting = { name: :asc }
  end
end
