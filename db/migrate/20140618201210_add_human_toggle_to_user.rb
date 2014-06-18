class AddHumanToggleToUser < ActiveRecord::Migration
  def change
    add_column :users, :sees_filtered_totals, :boolean, null: false, default: true
  end
end
