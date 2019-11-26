# frozen_string_literal: true

class User < ApplicationRecord
  APPROVAL_STATUSES = %w[pending_approval approved not_approved].freeze

  validates :email, presence: true
  validates :approval_status, inclusion: APPROVAL_STATUSES

  has_many :memberships, dependent: :destroy
  has_many :affiliates, lambda {
                          order 'affiliates.display_name, affiliates.ID ASC'
                        },
           through: :memberships
  has_many :watchers, dependent: :destroy
  belongs_to :default_affiliate, class_name: 'Affiliate'

  before_validation :downcase_email
  before_validation :set_initial_approval_status, on: :create
  after_validation :set_default_flags, on: :create

  after_create :deliver_welcome_to_new_user_added_by_affiliate, if: :invited

  before_update :detect_deliver_welcome_email
  after_create :ping_admin
  after_update :send_welcome_to_new_user_email, if: :deliver_welcome_email_on_update

  attr_accessor :invited, :skip_welcome_email, :inviter
  attr_reader :deliver_welcome_email_on_update

  scope :approved_affiliate, lambda {
    where(is_affiliate: true, approval_status: 'approved')
  }
  scope :not_approved, -> { where(approval_status: 'not_approved') }
  scope :approved, -> { where(approval_status: 'approved') }
  scope :not_active,
        lambda {
          where('current_login_at <= ? OR (current_login_at IS NULL AND created_at <=? )',
                90.days.ago,
                90.days.ago)
        }

  acts_as_authentic do |c|
    c.login_field = :email
    c.validate_email_field = true
    c.validate_login_field = false
    c.ignore_blank_passwords  = true
    c.validate_password_field = false
    c.logged_in_timeout = 1.hour
  end

  APPROVAL_STATUSES.each do |status|
    define_method "is_#{status}?" do
      approval_status == status
    end

    define_method "set_approval_status_to_#{status}" do
      self.approval_status = status
    end
  end

  # commented out for now but will refactor later for login_dot_gov
  # validate do |user|
  #   if user.organization_name.blank? && !user.invited
  #     user.errors.add(:base, "Federal government agency can't be blank")
  #   end
  # end

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

  # authlogic magic state
  def approved?
    approval_status != 'not_approved'
  end

  def complete_registration(attributes)
    self.email_verification_token = nil
    self.set_approval_status_to_approved
    !requires_manual_approval? && update(attributes)
  end

  def self.new_invited_by_affiliate(inviter, affiliate, attributes)
    new_user = User.new(attributes)
    new_user.inviter = inviter
    new_user.invited = true
    new_user.affiliates << affiliate
    new_user
  end

  def affiliate_names
    affiliates.collect(&:name).join(',')
  end

  def send_new_affiliate_user_email(affiliate, inviter_user)
    Emailer.new_affiliate_user(affiliate, self, inviter_user).deliver_now
  end

  def add_to_affiliate(affiliate, source)
    affiliate.users << self unless affiliates.include?(affiliate)
    audit_trail_user_added(affiliate, source)
  end

  def remove_from_affiliate(affiliate, source)
    Membership.where(user_id: id, affiliate_id: affiliate.id).destroy_all
    audit_trail_user_removed(affiliate, source)
  end

  def self.from_omniauth(auth)
    find_or_create_by(email: auth.info.email).tap do |user|
      user.update(uid: auth.uid)
    end
  end

  private

  def ping_admin
    Emailer.new_user_to_admin(self).deliver_now
  end

  def deliver_welcome_to_new_user_added_by_affiliate
    Emailer.
      welcome_to_new_user_added_by_affiliate(affiliates.first, self, inviter).
      deliver_now
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
    set_approval_status_to_pending_approval if approval_status.blank? || invited
  end

  def downcase_email
    self.email = self.email.downcase if self.email.present?
  end

  def set_default_flags
    if is_affiliate? &&
       !has_government_affiliated_email? &&
       !invited
      self.requires_manual_approval = true
      set_approval_status_to_pending_approval
    else
      set_approval_status_to_approved
    end

    self.welcome_email_sent = true if is_developer? && !skip_welcome_email
  end

  def send_welcome_to_new_user_email
    Emailer.welcome_to_new_user(self).deliver_now
  end

  def audit_trail_user_added(site, source)
    log_note_for_user('added', 'to', site, source)
  end

  def audit_trail_user_removed(site, source)
    log_note_for_user('removed', 'from', site, source)
  end

  def log_note_for_user(added_or_removed, to_or_from, site, source)
    note = "#{source} #{added_or_removed} User #{id}, #{email}, #{to_or_from}
            Affiliate #{site.id}, #{site.display_name} [#{site.name}].".squish
    Rails.logger.info(note)
  end
end
