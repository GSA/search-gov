class CreateWatchers < ActiveRecord::Migration
  def change
    create_table :watchers do |t|
      t.references :user
      t.references :affiliate
      t.string :name
      t.string :check_interval
      t.string :throttle_period
      # t.references :scenario
      t.timestamps
    end
  end
end
