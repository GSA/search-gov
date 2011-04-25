class AddWelcomeEmailSentToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :welcome_email_sent, :boolean, :default => false, :null => false
    update("update users set welcome_email_sent = true where approval_status = 'approved'")
  end

  def self.down
    remove_column :users, :welcome_email_sent
  end
end
