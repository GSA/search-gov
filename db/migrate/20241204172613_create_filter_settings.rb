class CreateFilterSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :filter_settings do |t|
      t.integer :affiliate_id

      t.timestamps
    end
  end
end
