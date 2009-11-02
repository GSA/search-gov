class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email, :null => false
      t.string :perishable_token
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.integer :login_count, :null => false, :default => 0
      t.string :time_zone, :null=> false, :default => 'Eastern Time (US & Canada)'
      t.boolean :is_affiliate_admin, :null => false, :default => false
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string :last_login_ip
      t.string :current_login_ip

      t.timestamps
    end

    add_index :users, :perishable_token
    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table :users
  end
end
