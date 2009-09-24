class CreateJoinTableQueryGroupsAndGroupedQueries < ActiveRecord::Migration
  def self.up
    create_table :grouped_queries_query_groups, :id => false do |t|
      t.references :query_group, :null=>false
      t.references :grouped_query, :null=>false
    end
    add_index :grouped_queries_query_groups, [:query_group_id, :grouped_query_id], :unique=> true, :name=>"joinindex"
  end

  def self.down
    drop_table :grouped_queries_query_groups
  end
end
