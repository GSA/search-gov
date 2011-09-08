class Admin::BoostedContentsController < Admin::AdminController
  active_scaffold :boosted_content do |config|
    config.columns = [:description, :title, :url, :locale, :status, :publish_start_on, :publish_end_on]
    list.columns.exclude :publish_start_on, :publish_end_on
    config.columns[:publish_start_on].options = { :value => Date.current }
    config.columns[:locale].form_ui = :select
    config.columns[:locale].options = {:options => SUPPORTED_LOCALES.map{|locale| [locale.to_sym, locale]}}
    config.columns[:status].form_ui = :select
    config.columns[:status].options = {:options => BoostedContent::STATUS_OPTIONS}
  end

  def after_create_save(boosted_content)
    Sunspot.index(boosted_content)
  end

  def after_update_save(boosted_content)
    Sunspot.index(boosted_content)
  end
end
