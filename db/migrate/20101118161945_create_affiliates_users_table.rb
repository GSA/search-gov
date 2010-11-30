class CreateAffiliatesUsersTable < ActiveRecord::Migration
  def self.up
    create_table :affiliates_users, :id => false do |t|
      t.references :affiliate, :nil => false
      t.references :user, :nil => false
    end
    add_index :affiliates_users, [:affiliate_id, :user_id], :unique => true
    rename_column :affiliates, :user_id, :owner_id
    Affiliate.all.each do |affiliate|
      affiliate.users << affiliate.owner if affiliate.owner
    end
  end

  def self.down
    rename_column :affiliates, :owner_id, :user_id
    drop_table :affiliates_users
  end
end
