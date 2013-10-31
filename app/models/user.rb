class User < ActiveRecord::Base
  APPROVAL_STATUSES = %w( pending_email_verification pending_approval approved not_approved )
  validates_presence_of :email
  validates_presence_of :contact_name
  validates_presence_of :organization_name, :if => :strict_mode
  validates_inclusion_of :approval_status, :in => APPROVAL_STATUSES
  validates_acceptance_of :terms_of_service
  validates_acceptance_of :affiliation_with_government, :message => "is required to register for an account"
  has_many :memberships, :dependent => :destroy
  has_many :affiliates, :order => 'affiliates.display_name, affiliates.ID ASC', through: :memberships
  belongs_to :default_affiliate, class_name: 'Affiliate'
  before_validation :set_initial_approval_status, :on => :create
  after_validation :set_is_affiliate, :on => :create
  after_validation :set_default_flags, :on => :create
  after_create :ping_admin
  after_create :deliver_email_verification
  after_update :deliver_welcome_email
  attr_accessor :government_affiliation, :strict_mode, :invited, :skip_welcome_email, :terms_of_service, :inviter, :require_password
  attr_protected :strict_mode, :invited, :require_password, :inviter, :is_affiliate, :is_affiliate_admin, :approval_status, :requires_manual_approval, :welcome_email_sent
  scope :approved_affiliate, where(:is_affiliate => true, :approval_status => 'approved')
  scope :not_approved, where(approval_status: 'not_approved')

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.perishable_token_valid_for 1.hour
    c.disable_perishable_token_maintenance(true)
  end

  APPROVAL_STATUSES.each do |status|
    define_method "is_#{status}?" do
      approval_status == status
    end

    define_method "set_approval_status_to_#{status}" do
      self.approval_status = status
    end
  end

  def deliver_password_reset_instructions!(host_with_port)
    reset_perishable_token!
    Emailer.password_reset_instructions(self, host_with_port).deliver
  end

  def to_label
    contact_name
  end

  def is_affiliate_or_higher
    is_affiliate || is_affiliate_admin
  end

  def is_developer?
    !is_affiliate_or_higher
  end

  def has_government_affiliated_email?
    email =~ /\.(gov|mil|fed\.us)$|(\.|@)state\.[a-z]{2}\.us$/i
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
      if requires_manual_approval?
        set_approval_status_to_pending_approval
      else
        set_approval_status_to_approved
        self.welcome_email_sent = true
      end

      self.email_verification_token = nil
      save!
      Emailer.welcome_to_new_user(self).deliver if is_approved?
      true
    else
      false
    end
  end

  def complete_registration(attributes)
    self.require_password = true
    self.email_verification_token = nil
    self.set_approval_status_to_approved
    !self.requires_manual_approval? and self.update_attributes(attributes)
  end

  def self.new_invited_by_affiliate(inviter, affiliate, attributes)
    default_attributes = { :government_affiliation => "1" }
    new_user = User.new(attributes.merge(default_attributes))
    new_user.randomize_password
    new_user.inviter = inviter
    new_user.invited = true
    new_user.affiliates << affiliate
    new_user
  end

  def affiliate_names
    affiliates.collect(&:name).join(',')
  end

  private

  def require_password?
    require_password.nil? ? super : (require_password == true)
  end

  def ping_admin
    Emailer.new_user_to_admin(self).deliver
  end

  def deliver_email_verification
    if is_pending_email_verification?
      reset_email_verification_token!
      invited ? deliver_welcome_to_new_user_added_by_affiliate : deliver_new_user_email_verification
    end
  end

  def deliver_new_user_email_verification
    Emailer.new_user_email_verification(self).deliver
  end

  def deliver_welcome_to_new_user_added_by_affiliate
    Emailer.welcome_to_new_user_added_by_affiliate(affiliates.first, self, inviter).deliver
  end

  def reset_email_verification_token!
    current_perishable_token = perishable_token
    self.email_verification_token = reset_perishable_token.downcase
    self.perishable_token = current_perishable_token
    save!
  end

  def deliver_welcome_email
    if is_approved? and !welcome_email_sent?
      self.welcome_email_sent = true
      save!
      Emailer.welcome_to_new_user(self).deliver
    end
  end

  def set_is_affiliate
    unless self.government_affiliation.blank?
      self.is_affiliate = signed_up_to_be_an_affiliate? ? 1 : 0
    end
  end

  def set_initial_approval_status
    set_approval_status_to_pending_email_verification if self.approval_status.blank? or invited
  end

  def set_default_flags
    self.requires_manual_approval = true if is_affiliate? and !has_government_affiliated_email? and !invited
    self.welcome_email_sent = true if (is_developer? and !skip_welcome_email) or invited
  end
end
