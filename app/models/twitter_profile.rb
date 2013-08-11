class TwitterProfile < ActiveRecord::Base
  has_many :tweets, :primary_key => :twitter_id, :dependent => :destroy
  has_many :affiliate_twitter_settings, dependent: :destroy
  has_many :affiliates, through: :affiliate_twitter_settings
  has_and_belongs_to_many :twitter_lists
  validates_presence_of :screen_name
  validate :must_have_valid_screen_name, :if => :screen_name?
  validates_presence_of :twitter_id, :profile_image_url, :if => :get_twitter_user
  validates_uniqueness_of :twitter_id
  before_validation :normalize_screen_name
  before_validation :lookup_twitter_id
  scope :active, joins(:affiliate_twitter_settings).uniq
  scope :show_lists_enabled, active.where('affiliate_twitter_settings.show_lists = 1').order('twitter_profiles.updated_at asc, twitter_profiles.id asc').uniq

  def recent
    self.tweets.recent
  end

  def link_to_profile
    "http://twitter.com/#{screen_name}"
  end

  def self.affiliate_twitter_ids
    active.select(:twitter_id).uniq.map(&:twitter_id)
  end

  def self.find_and_update_or_create!(twitter_user)
    twitter_profile = where(twitter_id: twitter_user.id).first_or_initialize
    twitter_profile.screen_name = twitter_user.screen_name
    twitter_profile.name = twitter_user.name
    twitter_profile.profile_image_url = twitter_user.profile_image_url
    twitter_profile.save!
    twitter_profile
  end

  def profile_complete?
    twitter_id.present? && screen_name.present? && name.present? && profile_image_url.present?
  end

  private

  def get_twitter_user
    return if profile_complete?
    @twitter_user ||= Twitter.user(screen_name) rescue nil
  end

  def must_have_valid_screen_name
    errors.add(:screen_name, 'is invalid') unless profile_complete? || get_twitter_user
  end

  def normalize_screen_name
    screen_name.gsub!(/[@ ]/,'') unless screen_name.nil?
  end

  def lookup_twitter_id
    if screen_name.present? and twitter_id.nil?
      twitter_user = get_twitter_user
      if twitter_user
        self.twitter_id = twitter_user.id
        self.name = twitter_user.name
        self.profile_image_url = twitter_user.profile_image_url
      end
    end
  end
end
