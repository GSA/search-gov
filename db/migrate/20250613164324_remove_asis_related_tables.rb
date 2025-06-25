class RemoveAsisRelatedTables < ActiveRecord::Migration[7.1]
  def up
    # # Remove oasis_mrss_name column from rss_feed_urls table
    # remove_column :rss_feed_urls, :oasis_mrss_name, :string

    # # Drop flickr_profiles table
    # drop_table :flickr_profiles

    # # Drop image_search_labels table
    # drop_table :image_search_labels

    # # Remove OASIS and OSPEL search modules
    # execute "DELETE FROM search_modules WHERE tag IN ('OASIS', 'OSPEL')"
  end

  def down
    # Recreate flickr_profiles table
    create_table :flickr_profiles do |t|
      t.string :url
      t.string :profile_type
      t.string :profile_id
      t.integer :affiliate_id
      t.timestamps precision: nil
    end
    add_index :flickr_profiles, :affiliate_id

    # Recreate image_search_labels table
    create_table :image_search_labels do |t|
      t.integer :affiliate_id, null: false
      t.string :name, null: false
      t.timestamps precision: nil
    end
    add_index :image_search_labels, :affiliate_id, unique: true

    # Add back oasis_mrss_name column
    add_column :rss_feed_urls, :oasis_mrss_name, :string

    # Recreate search modules
    execute "INSERT INTO search_modules (tag, display_name, created_at, updated_at) VALUES
             ('OASIS', 'Image Results (Search.gov)', NOW(), NOW()),
             ('OSPEL', 'Spelling Suggestions (Search.gov Images)', NOW(), NOW())"
  end
end
