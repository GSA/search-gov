class DropAffiliatesUsers < ActiveRecord::Migration
  def up
    drop_table :affiliates_users
  end

  def down
    create_table "affiliates_users", :id => false, :force => true do |t|
      t.integer "affiliate_id"
      t.integer "user_id"
    end

    execute 'INSERT INTO affiliates_users (affiliate_id, user_id) select affiliate_id, user_id from memberships'

    add_index "affiliates_users", ["affiliate_id", "user_id"], :name => "index_affiliates_users_on_affiliate_id_and_user_id", :unique => true
    add_index "affiliates_users", ["user_id"], :name => "index_affiliates_users_on_user_id"
  end
end
