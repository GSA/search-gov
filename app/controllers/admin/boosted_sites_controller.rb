class Admin::BoostedSitesController < Admin::AdminController
  active_scaffold :boosted_site do |config|
    config.list.per_page = 100
    config.list.columns.exclude :affiliate, :created_at
    config.create.columns = [:description, :title, :url]
    config.update.columns = [:description, :title, :url]
  end
  
  def conditions_for_collection
    ['ISNULL(affiliate_id)']
  end
  
  def after_create_save(boosted_site)
    Sunspot.index(boosted_site)
  end
  
  def after_update_save(boosted_site)
    Sunspot.index(boosted_site)
  end
end