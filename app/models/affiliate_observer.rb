class AffiliateObserver < ActiveRecord::Observer
  def after_create(affiliate)
    image_search_label = affiliate.build_image_search_label
    image_search_label.save!
  end
end
