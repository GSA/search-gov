class Tweet < ActiveRecord::Base
  belongs_to :twitter_profile, :primary_key => :twitter_id
  validates_presence_of :tweet_id, :tweet_text, :published_at, :twitter_profile_id
  validates_uniqueness_of :tweet_id
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

  def link_to_tweet
    "http://twitter.com/#{twitter_profile.screen_name}/status/#{tweet_id}"
  end
end