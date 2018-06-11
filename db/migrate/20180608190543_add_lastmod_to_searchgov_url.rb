class AddLastmodToSearchgovUrl < ActiveRecord::Migration
  def change
    add_column :searchgov_urls, :lastmod, :datetime
  end
end
