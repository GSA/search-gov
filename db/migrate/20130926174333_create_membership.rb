class CreateMembership < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :user, null: false
      t.references :affiliate, null: false
      t.boolean :gets_daily_snapshot_email, default: false, null: false
      t.timestamps
    end
  end
end
