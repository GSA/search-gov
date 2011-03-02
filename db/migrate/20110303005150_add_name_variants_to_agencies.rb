class AddNameVariantsToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :name_variants, :text
  end

  def self.down
    remove_column :agencies, :name_variants
  end
end
