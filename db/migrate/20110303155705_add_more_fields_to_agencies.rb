class AddMoreFieldsToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :toll_free_phone, :string, :limit => 15
    add_column :agencies, :tty_phone, :string, :limit => 15
    add_column :agencies, :twitter_username, :string, :limit => 18
    add_column :agencies, :youtube_username, :string, :limit => 40
    add_column :agencies, :facebook_username, :string, :limit => 75
    add_column :agencies, :flickr_username, :string, :limit => 50
    change_column :agencies, :phone, :string, :limit => 15
  end

  def self.down
    change_column :agencies, :phone, :string
    remove_column :agencies, :flickr_username
    remove_column :agencies, :facebook_username
    remove_column :agencies, :youtube_username
    remove_column :agencies, :twitter_username
    remove_column :agencies, :tty_phone
    remove_column :agencies, :toll_free_phone
  end
end
