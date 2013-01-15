class Admin::AffiliateBoostedContentsController < Admin::AdminController
  active_scaffold :boosted_content do |config|
    config.label = 'Best Bets: Text'
    config.actions.exclude :create, :update
    config.list.columns =[:affiliate, :title, :status, :url, :publish_start_on, :publish_end_on]
    config.columns[:affiliate].label = 'Site'
  end

  def conditions_for_collection
    ['NOT ISNULL(affiliate_id)']
  end

  def after_create_save(boosted_content)
    Sunspot.index(boosted_content)
  end

  def after_update_save(boosted_content)
    Sunspot.index(boosted_content)
  end
end
