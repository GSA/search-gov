class Admin::RssFeedsController < Admin::AdminController
  active_scaffold :rss_feed do |config|
    config.columns = [:name, :owner, :created_at, :updated_at]
    config.list.sorting = { name: :asc }
    config.actions = [:list, :nested]
  end

  def conditions_for_collection
    { owner_type: Affiliate.name }
  end
end
