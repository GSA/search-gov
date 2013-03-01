class AddIndexToNavigations < ActiveRecord::Migration
  def change
    add_index :navigations, [:navigable_id, :navigable_type]
  end
end
