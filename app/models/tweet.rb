require 'net/http'
require 'uri'

class Tweet < ActiveRecord::Base
  before_save :sanitize_tweet_text
  belongs_to :twitter_profile, :primary_key => :twitter_id
  validates_presence_of :tweet_id, :tweet_text, :published_at, :twitter_profile_id
  validates_uniqueness_of :tweet_id
  scope :recent, :order => 'published_at DESC', :limit => 10
  serialize :urls, Array

  searchable do
    text :tweet_text, :stored => true
    time :published_at
    integer :twitter_profile_id, :multiple => true
  end

  class << self
    include QueryPreprocessor

    def search_for(query, twitter_profile_ids, since_ts = nil, page = 1, per_page = 3)
      sanitized_query = preprocess(query)
      return nil if sanitized_query.blank?
      search do
        fulltext sanitized_query do
          highlight :tweet_text, :frag_list_builder => :single
        end
        with(:published_at).greater_than(since_ts) if since_ts
        with(:twitter_profile_id, twitter_profile_ids)
        order_by(:published_at, :desc)
        paginate :page => page, :per_page => per_page
      end
    end
  end

  def sanitize_tweet_text
    self.tweet_text = Sanitize.clean(tweet_text).squish if tweet_text
  end

  def link_to_tweet
    "http://twitter.com/#{twitter_profile.screen_name}/status/#{tweet_id}"
  end
end