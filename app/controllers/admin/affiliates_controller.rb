class Admin::AffiliatesController < Admin::AdminController
  active_scaffold :affiliate do |config|
    config.columns = [:name, :domains, :header, :footer]
    config.list.sorting = { :name => :asc }
  end
end