class ChangeImageSearchLabelToNullableOnAffiliates < ActiveRecord::Migration
  def self.up
    change_column_null :affiliates, :image_search_label, true
    rename_column :affiliates, :image_search_label, :old_image_search_label
  end

  def self.down
    rename_column :affiliates, :old_image_search_label, :image_search_label
    change_column_null :affiliates, :image_search_label, false
  end
end
