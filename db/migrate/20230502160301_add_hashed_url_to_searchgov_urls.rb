class AddHashedUrlToSearchgovUrls < ActiveRecord::Migration[7.0]
  def change
    add_column :searchgov_urls, :hashed_url, :string, limit: 64
  end
end
