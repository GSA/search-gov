class AddFilterOnlyExactPhraseToSaytFilter < ActiveRecord::Migration
  def self.up
    add_column :sayt_filters, :filter_only_exact_phrase, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :sayt_filters, :filter_only_exact_phrase
  end
end
