class RemovePreviousHeaderAndPreviousFooterFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :previous_header
    remove_column :affiliates, :previous_footer
  end

  def self.down
    add_column :affiliates, :previous_footer, :text
    add_column :affiliates, :previous_header, :text
  end
end
