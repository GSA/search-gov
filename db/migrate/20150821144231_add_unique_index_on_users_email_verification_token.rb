class AddUniqueIndexOnUsersEmailVerificationToken < ActiveRecord::Migration
  def up
    add_index :users, :email_verification_token, unique: true
  end

  def down
    remove_index :users, :email_verification_token
  end
end
