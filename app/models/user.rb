class User < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email
  attr_protected :is_affiliate, :is_affiliate_admin
  has_many :affiliates

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.perishable_token_valid_for 1.hour
    c.disable_perishable_token_maintenance(true)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Emailer.deliver_password_reset_instructions(self)
  end

  def to_label
    contact_name
  end

end
