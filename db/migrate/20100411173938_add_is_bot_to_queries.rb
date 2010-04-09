class AddIsBotToQueries < ActiveRecord::Migration
  def self.up
    add_column :queries, :is_bot, :boolean
  end

  def self.down
    remove_column :queries, :is_bot
  end
end
