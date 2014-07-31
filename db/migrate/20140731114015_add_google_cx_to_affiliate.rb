class AddGoogleCxToAffiliate < ActiveRecord::Migration
  def change
    add_column :affiliates, :google_cx, :string
  end
end
