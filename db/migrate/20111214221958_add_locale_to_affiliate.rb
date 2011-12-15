class AddLocaleToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :locale, :string, :default => 'en', :null => false
  end

  def self.down
    remove_column :affiliates, :locale
  end
end
