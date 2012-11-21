class RemoveMobileHomepageUrlFromAffiliates < ActiveRecord::Migration
  def up
    remove_column :affiliates, :mobile_homepage_url
  end

  def down
    add_column :affiliates, :mobile_homepage_url, :string
  end
end
