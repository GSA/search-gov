class CreateSaytFilters < ActiveRecord::Migration
  def self.up
    create_table :sayt_filters do |t|
      t.string :phrase, :null => false
      t.timestamps
    end
    add_index :sayt_filters, :phrase, :unique => true
  end

  def self.down
    drop_table :sayt_filters
  end
end
