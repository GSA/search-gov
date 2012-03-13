class RemoveAnalyticsTables < ActiveRecord::Migration
  def self.up
    drop_table :query_groups
    drop_table :grouped_queries
    drop_table :grouped_queries_query_groups
    drop_table :daily_popular_query_groups
    drop_table :monthly_popular_queries
    drop_table :moving_queries
    remove_column :users, :is_analyst
    remove_column :users, :is_analyst_admin
  end

  def self.down
    add_column :users, :is_analyst, :boolean, :default => false, :null => false
    add_column :users, :is_analyst_admin, :boolean, :default => false, :null => false
    
    create_table "query_groups", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "query_groups", ["name"], :name => "index_query_groups_on_name", :unique => true
    
    create_table "grouped_queries", :force => true do |t|
      t.string   "query",      :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "grouped_queries", ["query"], :name => "index_grouped_queries_on_query", :unique => true

    create_table "grouped_queries_query_groups", :id => false, :force => true do |t|
      t.integer "query_group_id",   :null => false
      t.integer "grouped_query_id", :null => false
    end
    add_index "grouped_queries_query_groups", ["query_group_id", "grouped_query_id"], :name => "joinindex", :unique => true
    
    create_table "daily_popular_query_groups", :force => true do |t|
      t.date    "day"
      t.integer "time_frame"
      t.string  "query_group_name"
      t.integer "times"
    end
    add_index "daily_popular_query_groups", ["day"], :name => "index_daily_popular_query_groups_on_day"
    
    create_table "monthly_popular_queries", :force => true do |t|
      t.integer  "year"
      t.integer  "month"
      t.string   "query"
      t.integer  "times"
      t.boolean  "is_grouped", :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "monthly_popular_queries", ["year", "month", "is_grouped"], :name => "index_monthly_popular_queries_on_year_and_month_and_is_grouped"

    create_table "moving_queries", :force => true do |t|
      t.date    "day",                    :null => false
      t.integer "times",                  :null => false
      t.string  "query",   :limit => 100, :null => false
      t.float   "mean",                   :null => false
      t.float   "std_dev",                :null => false
    end
    add_index "moving_queries", ["day", "times"], :name => "index_moving_queries_on_day_and_times"
  end
end
