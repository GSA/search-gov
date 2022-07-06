class RemoveGoogleCxFromAffiliates < ActiveRecord::Migration[6.1]
  def change
    remove_column :affiliates, :google_cx, :string
    remove_column :affiliates, :google_key, :string
  end
end
