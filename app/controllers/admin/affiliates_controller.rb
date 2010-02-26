class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.columns = [:name, :domains, :header, :footer, :boosted_sites, :created_at, :updated_at]
    config.list.sorting = { :name => :asc }
    config.update.columns = [:name, :domains, :header, :footer]
    config.create.columns = [:name, :domains, :header, :footer]    
  end

end