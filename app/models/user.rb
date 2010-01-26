class User < ActiveRecord::Base
  validates_presence_of :email
  validates_presence_of :phone
  validates_presence_of :zip
  validates_presence_of :organization_name
  validates_presence_of :address
  validates_presence_of :state
  validates_presence_of :time_zone
  validates_presence_of :contact_name
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\.gov$/i, :message => "must end in '.gov'", :on => :create
  attr_protected :is_affiliate, :is_affiliate_admin, :is_analyst
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
