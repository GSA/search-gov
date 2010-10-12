class Admin::BoostedSitesController < Admin::AdminController
  active_scaffold :boosted_site do |config|
    config.list.per_page = 100
    config.list.columns.exclude :affiliate, :created_at
  end
  
  def conditions_for_collection
    ['ISNULL(affiliate_id)']
  end
end