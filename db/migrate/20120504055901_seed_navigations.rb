class SeedNavigations < ActiveRecord::Migration
  def self.up
    unless Rails.env.test?
      RssFeed.all.each do |r|
        next unless r.navigation.nil?
        r.create_navigation(:affiliate_id => r.affiliate_id,
                            :position => r.position || 100,
                            :is_active => r.is_navigable)
      end

      DocumentCollection.all.each do |dc|
        next unless dc.navigation.nil?
        dc.create_navigation(:affiliate_id => dc.affiliate_id,
                             :position => dc.position || 100,
                             :is_active => dc.is_navigable)
      end
    end
  end

  def self.down
  end
end
