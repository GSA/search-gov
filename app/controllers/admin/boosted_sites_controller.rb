class Admin::BoostedSitesController < Admin::AdminController
  active_scaffold :boosted_site do |config|
    config.label = 'Search.USA.gov Boosted Sites'
    config.columns = [:description, :title, :url, :locale]
    config.columns[:locale].form_ui = :select
    config.columns[:locale].options = {:options => SUPPORTED_LOCALES.map{|locale| [locale.to_sym, locale]}}
    config.list.per_page = 100
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
