# frozen_string_literal: true

class AddOmniauthToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :provider
      t.string :uid
      t.index :uid, unique: true
      t.index %i[provider uid], unique: true
    end
  end
end