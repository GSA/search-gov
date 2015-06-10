class CreateRoutedQueries < ActiveRecord::Migration
  def change
    create_table :routed_queries do |t|
      t.references :affiliate
      t.string :url
      t.string :description

      t.timestamps
    end
    add_index :routed_queries, :affiliate_id
  end
end
