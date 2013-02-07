class AddIsRegexToSaytFilter < ActiveRecord::Migration
  def change
    add_column :sayt_filters, :is_regex, :boolean, :null => false, :default => false
  end
end
