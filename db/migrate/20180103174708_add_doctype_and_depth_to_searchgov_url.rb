class AddDoctypeAndDepthToSearchgovUrl < ActiveRecord::Migration
  def change
    add_column :searchgov_urls, :doctype, :string, limit: 10
    add_column :searchgov_urls, :crawl_depth, :integer
  end
end
