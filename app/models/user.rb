class User < ActiveRecord::Base
  APPROVAL_STATUSES = %w( pending_email_verification pending_approval approved not_approved )
  PASSWORD_FORMAT = /\A
    (?=.{8,}\z)        # Must contain 8 or more characters
    (?=.*\d)           # Must contain a digit
    (?=.*[a-zA-Z])     # Must contain a letter
    (?=.*[[:^alnum:]]) # Must contain a symbol
  /x

  validates_presence_of :email
  validates_presence_of :contact_name
  validates_inclusion_of :approval_status, :in => APPROVAL_STATUSES
  validates_format_of :password,
    with: PASSWORD_FORMAT,
    if: :require_password?,
    message: 'must include a combination of letters, numbers, and special characters.'
  validate :confirm_current_password, on: :update, if: :require_password_confirmation
  validate :new_password_differs_from_current, on: :update, if: ->(user) { user.password.present? }

  has_many :memberships, :dependent => :destroy
  has_many :affiliates, -> { order 'affiliates.display_name, affiliates.ID ASC' }, through: :memberships
  has_many :watchers, dependent: :destroy
  belongs_to :default_affiliate, class_name: 'Affiliate'

  before_validation :downcase_email
  before_validation :set_initial_approval_status, :on => :create
  after_validation :set_default_flags, :on => :create

  with_options if: :is_pending_email_verification? do
    after_create :deliver_email_verification
  end

  before_update :detect_deliver_welcome_email
  after_create :ping_admin
  after_update :send_welcome_to_new_user_email, if: :deliver_welcome_email_on_update
  before_update :require_email_verification, if: :email_changed?
  after_update :deliver_email_verification, if: :email_changed?

  before_save :set_password_updated_at
  after_save :push_to_nutshell
  attr_accessor :invited, :skip_welcome_email, :inviter, :require_password,
                :current_password, :require_password_confirmation
  attr_reader :deliver_welcome_email_on_update
  scope :approved_affiliate, -> { where(:is_affiliate => true, :approval_status => 'approved') }
  scope :not_approved, -> { where(approval_status: 'not_approved') }
  scope :approved_with_same_nutshell_contact, ->(user) {
    where(nutshell_id: user.nutshell_id, approval_status: 'approved')
  }

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.perishable_token_valid_for 1.hour
    c.disable_perishable_token_maintenance(true)
    c.require_password_confirmation = false
  end

  APPROVAL_STATUSES.each do |status|
    define_method "is_#{status}?" do
      approval_status == status
    end

    define_method "set_approval_status_to_#{status}" do
      self.approval_status = status
    end
  end

  validate do |user|
    if user.organization_name.blank? && !user.invited
      user.errors.add(:base, "Federal government agency can't be blank")
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token! if perishable_token_expired? || perishable_token.blank?
    Emailer.password_reset_instructions(self).deliver_now
  end

  def to_label
    "#{contact_name} <#{email}>"
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

  #authlogic magic state
  def approved?
    approval_status != 'not_approved'
  end

  def verify_email(token)
    return true if (is_approved? && email_verification_token == token)

    if is_pending_email_verification? and email_verification_token == token
      if requires_manual_approval?
        set_approval_status_to_pending_approval
      else
        set_approval_status_to_approved
      end

      save!
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
    new_user = User.new(attributes)
    new_user.password = SecureRandom.hex(10) + "MLPFTW2016!!!"
    new_user.inviter = inviter
    new_user.invited = true
    new_user.affiliates << affiliate
    new_user
  end

  def affiliate_names
    affiliates.collect(&:name).join(',')
  end

  def nutshell_approval_status
    if User.approved_with_same_nutshell_contact(self).count > 0
      'approved'
    else
      approval_status
    end
  end

  def send_new_affiliate_user_email(affiliate, inviter_user)
    Emailer.new_affiliate_user(affiliate, self, inviter_user).deliver_now
  end

  def add_to_affiliate(affiliate, source)
    affiliate.users << self unless self.affiliates.include? affiliate
    NutshellAdapter.new.push_site affiliate
    audit_trail_user_added(affiliate, source)
  end

  def remove_from_affiliate(affiliate, source)
    Membership.where(user_id: self.id, affiliate_id: affiliate.id).destroy_all
    NutshellAdapter.new.push_site affiliate
    audit_trail_user_removed(affiliate, source)
  end

  def requires_password_reset?
    password_updated_at.blank? || password_updated_at < 90.days.ago
  end

  private

  def require_password?
    require_password.nil? ? super : (require_password == true)
  end

  def ping_admin
    Emailer.new_user_to_admin(self).deliver_now
  end

  def deliver_email_verification
    assign_email_verification_token!
    invited ? deliver_welcome_to_new_user_added_by_affiliate : deliver_user_email_verification
  end

  def assign_email_verification_token!
    begin
      update_column(:email_verification_token, Authlogic::Random.friendly_token.downcase)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def deliver_user_email_verification
    Emailer.user_email_verification(self).deliver_now
  end

  def deliver_welcome_to_new_user_added_by_affiliate
    Emailer.welcome_to_new_user_added_by_affiliate(affiliates.first, self, inviter).deliver_now
  end

  def detect_deliver_welcome_email
    if is_approved? && !welcome_email_sent?
      self.welcome_email_sent = true
      @deliver_welcome_email_on_update = true
    else
      @deliver_welcome_email_on_update = false
    end
    true
  end

  def set_initial_approval_status
    set_approval_status_to_pending_email_verification if self.approval_status.blank? or invited
  end

  def downcase_email
    self.email = self.email.downcase if self.email.present?
  end

  def set_default_flags
    self.requires_manual_approval = true if is_affiliate? and !has_government_affiliated_email? and !invited
    self.welcome_email_sent = true if (is_developer? and !skip_welcome_email)
  end

  def push_to_nutshell
    if contact_name_changed? || email_changed? || approval_status_changed?
      NutshellAdapter.new.push_user self
    end
  end

  def send_welcome_to_new_user_email
    Emailer.welcome_to_new_user(self).deliver_now
  end

  def audit_trail_user_added(site, source)
    add_nutshell_note_for_user('added', 'to', site, source)
  end

  def audit_trail_user_removed(site, source)
    add_nutshell_note_for_user('removed', 'from', site, source)
  end

  def add_nutshell_note_for_user(added_or_removed, to_or_from, site, source)
    note = "#{source} #{added_or_removed} @[Contacts:#{self.nutshell_id}], #{self.email} #{to_or_from} @[Leads:#{site.nutshell_id}] #{site.display_name} [#{site.name}]."
    NutshellAdapter.new.new_note(self, note)
  end

  def set_password_updated_at
    self.password_updated_at = Time.now if password
  end

  def confirm_current_password
    errors[:current_password] << 'is invalid' unless valid_password?(current_password)
  end

  def new_password_differs_from_current
    # valid_password?(password) checks that password, when encrypted, matches the encrypted
    # password that is currently stored in the database
    if valid_password?(password)
      errors[:password] << 'is invalid: new password must be different from current password'
    end
  end

  def perishable_token_expired?
    perishable_token && updated_at < (Time.now - User.perishable_token_valid_for)
  end

  def require_email_verification
    set_approval_status_to_pending_email_verification
    self.requires_manual_approval = !has_government_affiliated_email?
    true
  end
end
