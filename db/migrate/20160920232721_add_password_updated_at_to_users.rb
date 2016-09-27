class AddPasswordUpdatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_updated_at, :datetime
  end
end
