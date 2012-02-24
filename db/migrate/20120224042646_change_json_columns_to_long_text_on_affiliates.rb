class ChangeJsonColumnsToLongTextOnAffiliates < ActiveRecord::Migration
  def self.up
    change_column :affiliates, :previous_fields_json, :longtext
    change_column :affiliates, :live_fields_json, :longtext
    change_column :affiliates, :staged_fields_json, :longtext
  end

  def self.down
    change_column :affiliates, :previous_fields_json, :text
    change_column :affiliates, :live_fields_json, :text
    change_column :affiliates, :staged_fields_json, :text
  end
end
