class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links do |t|
      t.integer :position
      t.string  :type
      t.string  :title
      t.string  :url
      t.integer :affiliate_id, foreign_key: true

      t.timestamps
    end
  end
end
