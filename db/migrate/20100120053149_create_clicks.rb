class CreateClicks < ActiveRecord::Migration
  def self.up
    create_table :clicks do |t|
      t.string :domain
      t.integer :count

      t.timestamps
    end
  end

  def self.down
    drop_table :clicks
  end
end
