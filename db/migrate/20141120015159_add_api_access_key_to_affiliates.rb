class AddApiAccessKeyToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :api_access_key, :string, null: false
  end
end
