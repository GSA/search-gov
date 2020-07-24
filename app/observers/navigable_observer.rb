class NavigableObserver < ActiveRecord::Observer
  DEFAULT_POSITION_AND_IS_ACTIVE_FLAG = [100, false]
  observe :image_search_label, :document_collection, :rss_feed

  def after_create(model)
    position, is_active = DEFAULT_POSITION_AND_IS_ACTIVE_FLAG
    return if model.instance_of?(RssFeed) && !model.owner.instance_of?(Affiliate)
    affiliate_id = model.instance_of?(RssFeed) ? model.owner_id : model.affiliate_id
    is_active = true if model.instance_of?(RssFeed) && model.is_managed?
    navigation = model.build_navigation(affiliate_id: affiliate_id,
                                        position: position,
                                        is_active: is_active)
    navigation.save!
  end
end
