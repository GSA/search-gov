class AddForceMobileFormatToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :force_mobile_format, :boolean, null: false, default: false
  end
end
