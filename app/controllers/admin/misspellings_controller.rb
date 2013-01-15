class Admin::MisspellingsController < Admin::AdminController
  active_scaffold :misspelling do |config|
    config.label = 'Type Ahead Misspellings'
    config.columns = [:wrong, :rite]
    config.list.sorting = { :wrong => :asc }
  end
end