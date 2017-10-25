class MakeSearchgovUrlIndexNonUnique < ActiveRecord::Migration
  def up
    remove_index(:searchgov_urls, name: 'index_searchgov_urls_on_url')
    add_index :searchgov_urls, :url
  end

  def down
    remove_index(:searchgov_urls, name: 'index_searchgov_urls_on_url')
    add_index :searchgov_urls, :url, unique: true, length: 250
  end
end
