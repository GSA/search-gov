class AddJsonColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :previous_fields_json, :text
    add_column :affiliates, :live_fields_json, :text
    add_column :affiliates, :staged_fields_json, :text
  end

  def self.down
    remove_column :affiliates, :staged_fields_json
    remove_column :affiliates, :live_fields_json
    remove_column :affiliates, :previous_fields_json
  end
end
