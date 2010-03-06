class Admin::AffiliatesController < Admin::AdminController

  active_scaffold :affiliate do |config|
    config.columns = [:name, :domains, :header, :footer, :template, :boosted_sites, :created_at, :updated_at]
    config.list.sorting = { :name => :asc }
    config.update.columns = [:name, :domains, :header, :footer, :template]
    config.create.columns = [:name, :domains, :header, :footer, :template]
  end

end
