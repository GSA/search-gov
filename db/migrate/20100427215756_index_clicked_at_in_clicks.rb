class IndexClickedAtInClicks < ActiveRecord::Migration
  def self.up
    add_index :clicks, :clicked_at
  end

  def self.down
    remove_index :clicks, :clicked_at
  end
end
