class PruneAgency < ActiveRecord::Migration
  def up
    remove_columns :agencies, :domain, :phone, :name_variants, :toll_free_phone, :tty_phone, :twitter_username, :youtube_username, :facebook_username, :flickr_url
  end

  def down
    add_column :agencies, :domain, :string
    add_column :agencies, :phone, :string, :limit => 15
    add_column :agencies, :name_variants, :text
    add_column :agencies, :toll_free_phone, :string, :limit => 15
    add_column :agencies, :tty_phone, :string, :limit => 15
    add_column :agencies, :twitter_username, :string, :limit => 18
    add_column :agencies, :youtube_username, :string, :limit => 40
    add_column :agencies, :facebook_username, :string, :limit => 75
    add_column :agencies, :flickr_username, :string, :limit => 50
  end
end
