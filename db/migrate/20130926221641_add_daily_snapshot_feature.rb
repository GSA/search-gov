class AddDailySnapshotFeature < ActiveRecord::Migration
  class Feature < ActiveRecord::Base
  end

  def self.up
    Feature.create(:internal_name => "daily_snapshot", :display_name => "Daily Snapshot Email")
  end

  def self.down
    Feature.find_by_internal_name("daily_snapshot").destroy
  end
end
