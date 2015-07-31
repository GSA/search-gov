class DowncaseEmailAddresses < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.update_attribute(:email, user.email.downcase)
    end
  end

  def down
  end
end
