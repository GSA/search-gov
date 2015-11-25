class AffiliateObserver < ActiveRecord::Observer
  def after_create(affiliate)
    image_search_label = affiliate.build_image_search_label
    image_search_label.save!
    ScopedKey.create!(affiliate_id: affiliate.id, key: KeenScopedKey.generate(affiliate.id))
  end
end
