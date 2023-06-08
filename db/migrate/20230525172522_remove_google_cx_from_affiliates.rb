class RemoveGoogleCxFromAffiliates < ActiveRecord::Migration[7.0]
  def change
    remove_column :affiliates, :google_cx, :string
    remove_column :affiliates, :google_key, :string
  end
end
