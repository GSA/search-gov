class NavigableObserver < ActiveRecord::Observer
  DEFAULT_POSITION_AND_IS_ACTIVE_FLAG = [100, false]
  observe :image_search_label, :document_collection

  def after_create(model)
    position, is_active = DEFAULT_POSITION_AND_IS_ACTIVE_FLAG
    navigation = model.build_navigation(affiliate_id: model.affiliate_id,
                                        position: position,
                                        is_active: is_active)
    navigation.save!
  end
end
