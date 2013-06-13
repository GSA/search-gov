class DropRobots < ActiveRecord::Migration
  def up
    drop_table :robots
  end

  def down
    create_table "robots", :force => true do |t|
      t.string   "domain",     :null => false
      t.text     "prefixes"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "robots", ["domain"], :name => "index_robots_on_domain"
  end
end
