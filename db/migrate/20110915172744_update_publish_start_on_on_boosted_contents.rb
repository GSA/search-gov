class UpdatePublishStartOnOnBoostedContents < ActiveRecord::Migration
  def self.up
    update "UPDATE boosted_contents SET publish_start_on = CURDATE() where publish_start_on IS NULL AND (publish_end_on IS NULL OR publish_end_on >= CURDATE())"
    update "UPDATE boosted_contents SET publish_start_on = publish_end_on - INTERVAL 1 DAY WHERE publish_start_on IS NULL AND publish_end_on < CURDATE()"
  end

  def self.down
  end
end
