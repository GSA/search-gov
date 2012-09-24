require 'net/http'
require 'uri'

class Tweet < ActiveRecord::Base
  before_save :convert_tco_links
  belongs_to :twitter_profile, :primary_key => :twitter_id
  validates_presence_of :tweet_id, :tweet_text, :published_at, :twitter_profile_id
  # validates_uniqueness_of :tweet_id
  scope :recent, :order => 'published_at DESC', :limit => 10

  searchable do
    text :tweet_text, :stored => true
    time :published_at
    integer :twitter_profile_id, :multiple => true
  end

  class << self
    include QueryPreprocessor

    def search_for(query, twitter_profile_ids, page = 1, per_page = 3)
      sanitized_query = preprocess(query)
      return nil if sanitized_query.blank?
      search do
        fulltext sanitized_query do
          highlight :tweet_text, :frag_list_builder => :single
        end
        with(:twitter_profile_id, twitter_profile_ids)
        order_by(:published_at, :desc)
        paginate :page => page, :per_page => per_page
      end
    end
  end

  def convert_tco_links
    while link = tweet_text.match(/http[s]{0,1}:\/\/t\.co\/[A-Za-z0-9]+/)
      uri = URI.parse(link.to_s)
      request = Net::HTTP::Head.new(uri.path)
      response = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(request) }
      self.tweet_text = tweet_text.gsub(link.to_s, response['location'])
    end
  end

  def link_to_tweet
    "http://twitter.com/#{twitter_profile.screen_name}/status/#{tweet_id}"
  end
end