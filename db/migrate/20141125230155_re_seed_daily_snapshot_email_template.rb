class ReSeedDailySnapshotEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['daily_snapshot']
  end

  def self.down
    EmailTemplate.where(name: 'daily_snapshot').destroy_all
  end
end
