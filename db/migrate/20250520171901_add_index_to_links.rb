class AddIndexToLinks < ActiveRecord::Migration[7.1]
  def change
    add_index :links, [:type, :affiliate_id]
  end
end
