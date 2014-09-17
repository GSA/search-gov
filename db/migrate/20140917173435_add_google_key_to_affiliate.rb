class AddGoogleKeyToAffiliate < ActiveRecord::Migration
  def change
    add_column :affiliates, :google_key, :string
  end
end
