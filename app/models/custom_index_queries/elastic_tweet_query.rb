# frozen_string_literal: true

class ElasticTweetQuery < ElasticTextFilteredQuery
  def initialize(options)
    super({ sort: 'published_at:desc' }.merge(options))
    @twitter_profile_ids = options[:twitter_profile_ids]
    @since_ts = options[:since]
    @text_fields = ['tweet_text']
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.child! { json.terms { json.twitter_profile_id @twitter_profile_ids } }
          json.child! { published_at_filter(json) } if @since_ts
        end
      end
    end
  end

  def published_at_filter(json)
    json.range do
      json.published_at do
        json.gt @since_ts
      end
    end
  end
end
