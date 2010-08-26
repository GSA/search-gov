class Admin::AffiliateTemplatesController < Admin::AdminController

  active_scaffold :affiliate_templates do |config|
    config.columns = [:name, :description, :stylesheet, :created_at, :updated_at]
    config.list.sorting = { :name => :asc }
    config.list.per_page = 100
    config.update.columns = [:name, :description, :stylesheet]
    config.create.columns = [:name, :description, :stylesheet]
  end

end