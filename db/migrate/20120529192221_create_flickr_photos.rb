class CreateFlickrPhotos < ActiveRecord::Migration
  def self.up
    create_table :flickr_photos do |t|
      t.boolean :is_public
      t.integer :farm
      t.string :title
      t.string :flickr_id
      t.string :server
      t.boolean :is_family
      t.string :secret
      t.string :owner
      t.boolean :is_friend
      t.string :last_update, :limit => 15
      t.string :url_sq
      t.string :url_t
      t.string :url_s
      t.string :url_q
      t.string :url_m
      t.string :url_n
      t.string :url_z
      t.string :url_c
      t.string :url_l
      t.string :url_o
      t.integer :width_sq
      t.integer :width_t
      t.integer :width_s
      t.integer :width_q
      t.integer :width_m
      t.integer :width_n
      t.integer :width_z
      t.integer :width_c
      t.integer :width_l
      t.integer :width_o
      t.integer :height_sq
      t.integer :height_t
      t.integer :height_s
      t.integer :height_q
      t.integer :height_m
      t.integer :height_n
      t.integer :height_z
      t.integer :height_c
      t.integer :height_l
      t.integer :height_o
      t.text :description
      t.float :latitude
      t.float :longitude
      t.integer :accuracy
      t.integer :license, :limit => 3
      t.text :tags
      t.text :machine_tags
      t.datetime :date_taken
      t.datetime :date_upload
      t.string :path_alias, :limit => 50
      t.string :owner_name, :limit => 50
      t.string :icon_server, :limit => 10
      t.integer :icon_farm
      t.references :affiliate
      t.timestamps
    end
  end

  def self.down
    drop_table :flickr_photos
  end
end
