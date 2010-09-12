class AddLocaleToFaqs < ActiveRecord::Migration
  def self.up
    add_column :faqs, :locale, :string, :default => 'en', :limit => 5
  end

  def self.down
    remove_column :faqs, :locale
  end
end
