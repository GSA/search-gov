class RemoveNotesFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :notes
  end

  def down
    add_column :users, :notes, :text
  end
end
