class TwitterProfile < ActiveRecord::Base
  has_many :tweets, :primary_key => :twitter_id, :dependent => :destroy
  has_many :affiliate_twitter_settings, dependent: :destroy
  has_many :affiliates, through: :affiliate_twitter_settings
  has_and_belongs_to_many :twitter_lists
  serialize :lists_members, Array
  validates_presence_of :screen_name
  validate :must_have_valid_screen_name, :if => :screen_name?
  validates_presence_of :twitter_id, :profile_image_url, :if => :get_twitter_user
  validates_uniqueness_of :twitter_id, :case_sensitive => false
  validates_uniqueness_of :screen_name, :case_sensitive => false
  before_validation :normalize_screen_name
  before_validation :lookup_twitter_id

  def recent
    self.tweets.recent
  end

  def link_to_profile
    "http://twitter.com/#{screen_name}"
  end

  def self.affiliate_twitter_ids
    TwitterProfile.joins(:affiliate_twitter_settings).
        select('twitter_profiles.twitter_id').
        map(&:twitter_id)
  end

  def self.with_show_list_enabled(limit = 15)
    TwitterProfile.joins(:affiliate_twitter_settings).
        where('affiliate_twitter_settings.show_lists = 1').
        order('twitter_profiles.updated_at asc').
        limit(limit)
  end

  private

  def get_twitter_user
    @twitter_user ||= Twitter.user(screen_name) rescue nil
  end

  def must_have_valid_screen_name
    errors.add(:screen_name, 'is invalid') unless get_twitter_user
  end

  def normalize_screen_name
    screen_name.gsub!(/[@ ]/,'') unless screen_name.nil?
  end

  def lookup_twitter_id
    if screen_name and twitter_id.nil?
      twitter_user = get_twitter_user
      if twitter_user
        self.twitter_id = twitter_user.id
        self.name = twitter_user.name
        self.profile_image_url = twitter_user.profile_image_url
      end
    end
  end
end
