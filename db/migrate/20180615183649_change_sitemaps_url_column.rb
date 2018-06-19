class ChangeSitemapsUrlColumn < ActiveRecord::Migration
  def up
    change_column :sitemaps, :url, :string, limit: 2000
  end

  def down
    change_column :sitemaps, :url, :string, limit: 255
  end
end
