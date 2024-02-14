class AddDisplayLogoOnlyToAffiliate < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :display_logo_only, :boolean, default: false
  end
end
