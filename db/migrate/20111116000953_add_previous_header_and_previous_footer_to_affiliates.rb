class AddPreviousHeaderAndPreviousFooterToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :previous_header, :text
    add_column :affiliates, :previous_footer, :text
  end

  def self.down
    remove_column :affiliates, :previous_footer
    remove_column :affiliates, :previous_header
  end
end
