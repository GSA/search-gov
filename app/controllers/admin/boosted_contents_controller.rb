class Admin::BoostedContentsController < Admin::AdminController
  active_scaffold :boosted_content do |config|
    config.label = 'Search.USA.gov Boosted Content'
    config.columns = [:description, :title, :url, :locale]
    config.columns[:locale].form_ui = :select
    config.columns[:locale].options = {:options => SUPPORTED_LOCALES.map{|locale| [locale.to_sym, locale]}}
    config.list.per_page = 100
  end
  
  def conditions_for_collection
    ['ISNULL(affiliate_id)']
  end
  
  def after_create_save(boosted_content)
    Sunspot.index(boosted_content)
  end
  
  def after_update_save(boosted_content)
    Sunspot.index(boosted_content)
  end
end
