class UpdateStatusOnBoostedContents < ActiveRecord::Migration
  def self.up
    update "UPDATE boosted_contents SET status = 'active' WHERE status IS NULL OR status = ''"
  end

  def self.down
  end
end
