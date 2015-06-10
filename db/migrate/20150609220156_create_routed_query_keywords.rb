class CreateRoutedQueryKeywords < ActiveRecord::Migration
  def change
    create_table :routed_query_keywords do |t|
      t.references :routed_query
      t.string :keyword

      t.timestamps
    end
    add_index :routed_query_keywords, [:routed_query_id, :keyword], unique: true
  end
end
