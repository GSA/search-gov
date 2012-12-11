class CreateBoostedContentKeywords < ActiveRecord::Migration
  def change
    create_table :boosted_content_keywords do |t|
      t.references :boosted_content, :null => false
      t.string :value, :null => false

      t.timestamps
    end
    add_index :boosted_content_keywords, :boosted_content_id
  end
end