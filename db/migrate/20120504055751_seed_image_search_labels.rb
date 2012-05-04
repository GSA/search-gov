class SeedImageSearchLabels < ActiveRecord::Migration
  def self.up
    Affiliate.all.each do |a|
      next unless a.image_search_label.nil?
      a.create_image_search_label(:name => a.old_image_search_label,
                                  :navigation_attributes => { :affiliate_id => a.id,
                                                              :position => 0,
                                                              :is_active => a.is_image_search_enabled? })
    end unless Rails.env.test?
  end

  def self.down
  end
end
