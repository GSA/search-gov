class Admin::MisspellingsController < Admin::AdminController
  active_scaffold :misspelling do |config|
    config.columns = [:wrong, :rite]
    config.list.sorting = { :wrong => :asc }
    config.list.per_page = 100
  end
end