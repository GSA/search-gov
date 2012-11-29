class RemoveUpdatedAtFromSitePages < ActiveRecord::Migration
  def change
    remove_column :site_pages, :updated_at
  end
end
