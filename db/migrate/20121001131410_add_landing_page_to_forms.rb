class AddLandingPageToForms < ActiveRecord::Migration
  def up
    add_column :forms, :landing_page_url, :string
  end

  def down
    remove_column :forms, :landing_page_url
  end
end
