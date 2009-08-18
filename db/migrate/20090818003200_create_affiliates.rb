class CreateAffiliates < ActiveRecord::Migration
  def self.up
    create_table :affiliates do |t|
      t.string :name, :null => false
      t.text :domains
      t.text :header
      t.text :footer
      t.timestamps
    end
    add_index :affiliates, :name, :unique => true
  end

  def self.down
    drop_table :affiliates
  end
end
