class AddExpirationDateToForms < ActiveRecord::Migration
  def change
    add_column :forms, :expiration_date, :date
  end
end
