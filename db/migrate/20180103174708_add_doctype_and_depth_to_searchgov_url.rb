class AddDoctypeAndDepthToSearchgovUrl < ActiveRecord::Migration
  def change
    add_column :searchgov_urls, :doctype, :string, limit: 10, null: false, default: 'html'
    add_column :searchgov_urls, :depth, :integer
  end
end
