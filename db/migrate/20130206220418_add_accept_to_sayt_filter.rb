class AddAcceptToSaytFilter < ActiveRecord::Migration
  def change
    add_column :sayt_filters, :accept, :boolean, :null => false, :default => false
  end
end
