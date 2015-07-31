class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.references :affiliate, index: true
      t.string :status
      t.text :text
      t.text :title
 
      t.timestamps
    end
    add_index :alerts, :affiliate_id, unique: true
  end
end
