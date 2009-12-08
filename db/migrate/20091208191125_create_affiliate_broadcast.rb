class CreateAffiliateBroadcast < ActiveRecord::Migration
  def self.up
    create_table :affiliate_broadcasts do |t|
      t.references :user, :null => false
      t.string :subject, :null => false
      t.text :body, :null => false
      t.timestamp(:created_at)
    end

    add_index :affiliate_broadcasts, :user_id
  end

  def self.down
    drop_table :affiliate_broadcasts
  end
end
