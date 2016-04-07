class AddI14YDateStampEnabledToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :i14y_date_stamp_enabled, :boolean, default: false, null: false
  end
end
