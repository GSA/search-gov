class AddIndexOnHashedUrl < ActiveRecord::Migration[7.0]
  def change
    add_index :searchgov_urls, :hashed_url, unique: true
  end
end
