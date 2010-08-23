class AddIsContextualToQueries < ActiveRecord::Migration
  def self.up
    add_column :queries, :is_contextual, :boolean, :default => false
  end

  def self.down
    remove_column :queries, :is_contextual
  end
end
