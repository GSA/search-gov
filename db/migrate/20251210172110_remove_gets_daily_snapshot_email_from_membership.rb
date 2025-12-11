class RemoveGetsDailySnapshotEmailFromMembership < ActiveRecord::Migration[7.1]
  def change
    remove_column :memberships, :gets_daily_snapshot_email, :boolean
  end
end
