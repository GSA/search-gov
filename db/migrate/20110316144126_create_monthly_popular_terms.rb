class CreateMonthlyPopularTerms < ActiveRecord::Migration
  def self.up
    create_table :monthly_popular_queries do |t|
      t.integer :year
      t.integer :month
      t.string :query
      t.integer :times
      t.boolean :is_grouped, :default => false

      t.timestamps
    end
    add_index :monthly_popular_queries, [:year, :month]
  end

  def self.down
    drop_table :monthly_popular_terms
  end
end
