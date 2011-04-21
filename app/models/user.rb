class User < ActiveRecord::Base
  APPROVAL_STATUSES = %w( pending_email_verification pending_approval approved not_approved )
  validates_presence_of :email
  validates_presence_of :contact_name
  validates_presence_of :api_key
  validates_uniqueness_of :api_key
  validates_presence_of :phone, :if => :strict_mode
  validates_presence_of :organization_name, :if => :strict_mode
  validates_presence_of :address, :if => :strict_mode
  validates_presence_of :city, :if => :strict_mode
  validates_presence_of :state, :if => :strict_mode
  validates_presence_of :zip, :if => :strict_mode
  validate_on_create :validate_government_affiliation
  validates_inclusion_of :approval_status, :in => APPROVAL_STATUSES
  attr_protected :is_affiliate, :is_affiliate_admin, :is_analyst
  attr_protected :approval_status
  has_and_belongs_to_many :affiliates
  before_validation :generate_api_key
  before_validation_on_create :set_approval_status
  after_validation_on_create :set_is_affiliate
  after_create :ping_admin
  after_create :deliver_email_verification
  after_create :welcome_user
  attr_accessor :government_affiliation
  attr_accessor :strict_mode
  attr_accessor :skip_welcome_email
  attr_protected :strict_mode

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.perishable_token_valid_for 1.hour
    c.disable_perishable_token_maintenance(true)
  end

  APPROVAL_STATUSES.each do |status|
    define_method "is_#{status}?" do
      approval_status == status
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

  def is_developer?
    !is_affiliate_or_higher
  end

  def has_government_affiliated_email?
    email =~ /\.(gov|mil)$/i
  end

  def signed_up_to_be_an_affiliate?
    government_affiliation == "1"
  end

  #authlogic magic state
  def approved?
    approval_status != 'not_approved'
  end

  def verify_email(token)
    return true if is_approved?
    if is_pending_email_verification? and email_verification_token == token
      self.approval_status = 'approved'
      self.email_verification_token = nil
      save!
      Emailer.deliver_welcome_to_new_user self
      return true
    else
      return false
    end
  end

  private

  def ping_admin
    Emailer.deliver_new_user_to_admin(self)
  end

  def deliver_email_verification
    if is_pending_email_verification?
      current_perishable_token = perishable_token
      self.email_verification_token = reset_perishable_token
      self.perishable_token = current_perishable_token
      save!
      Emailer.deliver_new_user_email_verification(self)
    end
  end

  def welcome_user
    unless self.skip_welcome_email
      Emailer.deliver_welcome_to_new_developer(self) if is_developer?
    end
  end

  def generate_api_key
    self.api_key = Digest::MD5.hexdigest("#{contact_name}:#{email}:#{Time.now.to_s}") if self.api_key.nil?
  end

  def set_is_affiliate
    unless self.government_affiliation.blank?
      self.is_affiliate = signed_up_to_be_an_affiliate? ? 1 : 0
    end
  end

  def validate_government_affiliation
    if self.government_affiliation.blank?
      errors.add_to_base("An option for government affiliation must be selected")
    end
  end

  def set_approval_status
    self.approval_status = 'approved' if self.approval_status.blank? and !signed_up_to_be_an_affiliate?
    self.approval_status = (has_government_affiliated_email? ? 'pending_email_verification' : 'pending_approval') if self.approval_status.blank?
  end
end
