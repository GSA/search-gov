class UpdatePublishStartOnOnFeaturedCollections < ActiveRecord::Migration
  def self.up
    update "UPDATE featured_collections SET publish_start_on = CURDATE() where publish_start_on IS NULL AND (publish_end_on IS NULL OR publish_end_on >= CURDATE())"
    update "UPDATE featured_collections SET publish_start_on = publish_end_on - INTERVAL 1 DAY WHERE publish_start_on IS NULL AND publish_end_on < CURDATE()"
    update "ALTER TABLE `featured_collections` CHANGE `publish_start_on` `publish_start_on` date NOT NULL"
  end

  def self.down
    update "ALTER TABLE `featured_collections` CHANGE `publish_start_on` `publish_start_on` date DEFAULT NULL"
  end
end
