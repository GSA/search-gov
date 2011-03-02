class AddAbbreviationToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :abbreviation, :string
  end

  def self.down
    remove_column :agencies, :abbreviation
  end
end
