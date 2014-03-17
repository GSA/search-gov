class Tweet < ActiveRecord::Base
  before_save :sanitize_tweet_text
  belongs_to :twitter_profile, :primary_key => :twitter_id
  validates_presence_of :tweet_id, :tweet_text, :published_at, :twitter_profile_id
  validates_uniqueness_of :tweet_id
  scope :recent, :order => 'published_at DESC', :limit => 10
  serialize :urls, Array

  def sanitize_tweet_text
    self.tweet_text = Sanitize.clean(tweet_text).squish if tweet_text
  end

  def link_to_tweet
    "http://twitter.com/#{twitter_profile.screen_name}/status/#{tweet_id}"
  end

  def language
    twitter_profile.affiliates.first.locale
  rescue
    Rails.logger.warn "Found Tweet with no affiliate, so defaulting to English locale"
    'en'
  end

end
