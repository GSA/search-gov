class AddLocaleToCalaisRelatedSearch < ActiveRecord::Migration
  def self.up
    add_column :calais_related_searches, :locale, :string, :null => false, :default => 'en'
  end

  def self.down
    remove_column :calais_related_searches, :locale
  end
end
