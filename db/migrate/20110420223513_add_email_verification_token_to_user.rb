class AddEmailVerificationTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :email_verification_token, :string
  end

  def self.down
    remove_column :users, :email_verification_token
  end
end
