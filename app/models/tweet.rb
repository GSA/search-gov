# frozen_string_literal: true

class Tweet < ApplicationRecord
  before_save :sanitize_tweet_text
  # temporary code to keep urls/safe_urls in sync until
  # we've migrated the data and swapped columns: https://cm-jira.usa.gov/browse/SRCH-3465
  before_save { self.safe_urls = urls.presence }
  belongs_to :twitter_profile, primary_key: :twitter_id
  validates :tweet_id, :tweet_text, :published_at, :twitter_profile_id, presence: true
  validates :tweet_id, uniqueness: true
  serialize :urls, Array

  def sanitize_tweet_text
    self.tweet_text = Sanitizer.sanitize(tweet_text).squish if tweet_text
  end

  def url_to_tweet
    "https://twitter.com/#{twitter_profile.screen_name}/status/#{tweet_id}"
  end

  def language
    twitter_profile.affiliates.first.indexing_locale
  rescue
    Rails.logger.warn 'Found Tweet with no affiliate, so defaulting to English locale'
    'en'
  end

  def as_json(_options = {})
    { text: tweet_text,
      url: url_to_tweet,
      name: twitter_profile.name,
      screen_name: twitter_profile.screen_name,
      profile_image_url: twitter_profile.profile_image_url,
      created_at: published_at.to_time.iso8601 }
  end

  def self.expire(days_back)
    where('published_at < ?', days_back.days.ago.beginning_of_day.to_s(:db)).
      in_batches.destroy_all
  end
end
