class ReSeedDailySnapshotEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['daily_snapshot']
  end

  def self.down
    EmailTemplate.destroy_all(:name => 'daily_snapshot')
  end
end
