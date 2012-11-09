class AddMobileHomepageUrlToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :mobile_homepage_url, :string
  end
end
