class TwitterProfile < ApplicationRecord
  has_many :tweets, :primary_key => :twitter_id, :dependent => :destroy
  has_many :affiliate_twitter_settings, dependent: :destroy
  has_many :affiliates, through: :affiliate_twitter_settings
  has_and_belongs_to_many :twitter_lists, join_table: :twitter_lists_twitter_profiles
  validates_presence_of :name, :profile_image_url, :screen_name, :twitter_id
  validates_uniqueness_of :twitter_id
  before_validation :normalize_screen_name, if: :screen_name?
  scope :active, -> { joins(:affiliate_twitter_settings).distinct }
  scope :show_lists_enabled, -> {
    active.
      where('affiliate_twitter_settings.show_lists = 1').
      order('twitter_profiles.updated_at asc, twitter_profiles.id asc').
      distinct
  }

  def link_to_profile
    "https://twitter.com/#{screen_name}"
  end

  def self.active_twitter_ids
    active.pluck(:twitter_id).uniq.sort
  end

  private

  def normalize_screen_name
    self.screen_name = screen_name.gsub(/[@ ]/,'')
  end
end
