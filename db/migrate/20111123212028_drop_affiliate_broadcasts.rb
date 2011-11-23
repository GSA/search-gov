class DropAffiliateBroadcasts < ActiveRecord::Migration
  def self.up
    drop_table :affiliate_broadcasts
  end

  def self.down
    create_table :affiliate_broadcasts do |t|
      t.references :user, :null => false
      t.string :subject, :null => false
      t.text :body, :null => false
      t.timestamp(:created_at)
    end

    add_index :affiliate_broadcasts, :user_id
  end
end
