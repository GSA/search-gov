class Admin::AffiliateBoostedContentsController < Admin::AdminController
  active_scaffold :boosted_content do |config|
    config.label = 'Affiliate Boosted Content'
    config.actions.exclude :create, :update
    config.list.columns.exclude :locale
  end

  def conditions_for_collection
    ['NOT ISNULL(affiliate_id)']
  end
end
