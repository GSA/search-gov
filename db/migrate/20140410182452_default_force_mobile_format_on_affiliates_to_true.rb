class DefaultForceMobileFormatOnAffiliatesToTrue < ActiveRecord::Migration
  def up
    change_column :affiliates, :force_mobile_format, :boolean, null: false, default: true
  end

  def down
    change_column :affiliates, :force_mobile_format, :boolean, null: false, default: false
  end
end
