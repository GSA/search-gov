class User < ActiveRecord::Base
  validates_presence_of :email
  validates_presence_of :phone, :if => :is_affiliate_or_higher
  validates_presence_of :zip, :if => :is_affiliate_or_higher
  validates_presence_of :organization_name, :if => :is_affiliate_or_higher
  validates_presence_of :address, :if => :is_affiliate_or_higher
  validates_presence_of :state, :if => :is_affiliate_or_higher
  validates_presence_of :time_zone, :if => :is_affiliate_or_higher
  validates_presence_of :contact_name
  validates_presence_of :api_key
  attr_protected :is_affiliate, :is_affiliate_admin, :is_analyst
  has_many :affiliates
  before_validation :generate_api_key
  after_create :ping_admin
  after_create :welcome_user

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.perishable_token_valid_for 1.hour
    c.disable_perishable_token_maintenance(true)
  end
  
  class << self
    def new_developer(params = {})
      developer = User.new(params)
      developer.is_affiliate = false
      developer
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Emailer.deliver_password_reset_instructions(self)
  end

  def to_label
    contact_name
  end
  
  def is_affiliate_or_higher
    is_affiliate || is_affiliate_admin || is_analyst
  end
  
  private
  
  def ping_admin
    Emailer.deliver_new_user_to_admin(self)
  end

  def welcome_user
    Emailer.deliver_welcome_to_new_user(self)
  end
  
  def generate_api_key
    self.api_key = Digest::MD5.hexdigest("#{contact_name}:#{email}:#{Time.now.to_s}") if self.api_key.nil?
  end
end
