class Admin::AffiliateBoostedSitesController < Admin::AdminController
  active_scaffold :boosted_site do |config|
    config.actions.exclude :create, :update
    config.list.per_page = 100
  end
  
  def conditions_for_collection
    ['NOT ISNULL(affiliate_id)']
  end
end