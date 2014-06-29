class DropLogfileTables < ActiveRecord::Migration
  def up
    drop_table :logfile_blocked_class_cs
    drop_table :logfile_blocked_ips
    drop_table :logfile_blocked_queries
    drop_table :logfile_blocked_regexps
    drop_table :logfile_blocked_user_agents
    drop_table :logfile_whitelisted_class_cs
  end

  def down
    create_table "logfile_blocked_class_cs", :force => true do |t|
      t.string "classc", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "logfile_blocked_class_cs", ["classc"], :name => "index_logfile_blocked_class_cs_on_classc", :unique => true

    create_table "logfile_blocked_ips", :force => true do |t|
      t.string "ip", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "logfile_blocked_ips", ["ip"], :name => "index_logfile_blocked_ips_on_ip", :unique => true

    create_table "logfile_blocked_queries", :force => true do |t|
      t.string "query", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "logfile_blocked_queries", ["query"], :name => "index_logfile_blocked_queries_on_query", :unique => true

    create_table "logfile_blocked_regexps", :force => true do |t|
      t.string "regexp", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "logfile_blocked_regexps", ["regexp"], :name => "index_logfile_blocked_regexps_on_regexp", :unique => true

    create_table "logfile_blocked_user_agents", :force => true do |t|
      t.string "agent", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "logfile_whitelisted_class_cs", :force => true do |t|
      t.string "classc", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end
end
