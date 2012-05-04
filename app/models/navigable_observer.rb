class NavigableObserver < ActiveRecord::Observer
  IMAGE_SEARCH_LABEL_POSITION_AND_IS_ACTIVE_FLAG = [0, true]
  DEFAULT_POSITION_AND_NOT_ACTIVE_FLAG = [100, false]
  observe :image_search_label, :document_collection, :rss_feed

  def after_create(model)
    position, is_active = model.instance_of?(ImageSearchLabel) ? IMAGE_SEARCH_LABEL_POSITION_AND_IS_ACTIVE_FLAG : DEFAULT_POSITION_AND_NOT_ACTIVE_FLAG
    navigation = model.build_navigation(:affiliate_id => model.affiliate_id,
                                        :position => position,
                                        :is_active => is_active)
    navigation.save!
  end
end