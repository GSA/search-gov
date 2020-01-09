class RemoveUserUnusedColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :password_updated_at, :datetime
    remove_column :users, :perishable_token, :string
    remove_column :users, :crypted_password, :string
    remove_column :users, :password_salt, :string
    remove_column :users, :failed_login_count, :integer, null: false, default: 0
    remove_column :users, :email_verification_token, :string
  end
end
