class AssociateAffiliatesWithUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :contact_name, :string
    add_column :users, :is_affiliate, :boolean, :null=> false, :default => false
    add_column :affiliates, :user_id, :integer
    Affiliate.all.each do |affiliate|
      next if affiliate.contact_email.blank?
      random_string = ActiveSupport::SecureRandom.hex(16)
      puts "Processing #{affiliate.name}: #{affiliate.contact_name} #{affiliate.contact_email}"
      user = User.find_by_email(affiliate.contact_email) || User.create!(:email=>affiliate.contact_email, :password=>random_string, :password_confirmation=>random_string, :contact_name=>affiliate.contact_name)
      user.update_attribute(:is_affiliate, true)
      affiliate.user= user
      affiliate.save
    end
    add_index :affiliates, :user_id
  end

  def self.down
    remove_index :affiliates, :user_id
    remove_column :affiliates, :user_id
    User.where('is_affiliate = 1').delete_all
    remove_column :users, :is_affiliate
    remove_column :users, :contact_name
  end
end
