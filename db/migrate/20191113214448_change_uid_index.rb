# frozen_string_literal: true

class ChangeUidIndex < ActiveRecord::Migration[5.0]
  def change
    change_table :users, bulk: true do
      remove_index :users, :uid
      add_index :users, :uid
    end
  end
end
