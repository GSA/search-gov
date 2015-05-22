class Admin::LanguagesController < Admin::AdminController
  active_scaffold :language do |config|
    config.list.sorting = { name: :asc }
  end
end
