class User < ActiveRecord::Base
  validates_presence_of :email
  validates_presence_of :phone
  validates_presence_of :zip
  validates_presence_of :organization_name
  validates_presence_of :address
  validates_presence_of :state
  validates_presence_of :time_zone
  validates_presence_of :contact_name
  validates_format_of :email, :with => /\.gov$/i, :message => "must end in '.gov'", :on => :create
  attr_protected :is_affiliate, :is_affiliate_admin, :is_analyst
  has_many :affiliates
  after_create :ping_admin
  after_create :welcome_user

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

  private
  def ping_admin
    Emailer.deliver_new_user_to_admin(self)
  end

  def welcome_user
    Emailer.deliver_welcome_to_new_user(self)
  end

end
