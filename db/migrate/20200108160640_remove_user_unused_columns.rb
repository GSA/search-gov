class RemoveUserUnusedColumns < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :password_updated_at, :datetime
    remove_column :users, :perishable_token, :string
    remove_column :users, :crypted_password, :string
    remove_column :users, :password_salt, :string
    remove_column :users, :failed_login_count, :integer, null: false, default: 0
    remove_column :users, :email_verification_token, :string
  end

  def down
    add_column :users, :password_updated_at, :datetime
    add_column :users, :perishable_token, :string
    add_column :users, :crypted_password, :string
    add_column :users, :password_salt, :string
    add_column :users, :failed_login_count, :integer, null: false, default: 0
    add_column :users, :email_verification_token, :string

    add_index :users, :perishable_token
    add_index :users, :email_verification_token, unique: true
  end
end
