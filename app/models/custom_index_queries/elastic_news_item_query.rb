# frozen_string_literal: true

class ElasticNewsItemQuery < ElasticTextFilterByPublishedAtQuery
  include ElasticTitleDescriptionBodyHighlightFields

  RSS_FEED_URL_REQUIRED =
    'NewsItem query requires at least one RSS feed URL to be present'

  def initialize(options)
    options[:sort] ||= 'published_at:desc'
    super
    @rss_feed_url_ids = feed_url_ids(options[:rss_feeds])
    @excluded_urls = options[:excluded_urls]&.map(&:url)
    @tags = options[:tags]
    @dublin_core_aggs = options.slice(*ElasticNewsItem::DUBLIN_CORE_AGG_NAMES).compact
    @text_fields = (options[:title_only] ? ['title'] : %w[body description title])
  end

  def query(json)
    filtered_query(json)

    json.post_filter do
      json.bool do
        json.must do
          @dublin_core_aggs.each do |facet, value|
            json.child! { json.term { json.set! facet, value } }
          end
        end
      end
    end if @dublin_core_aggs.present?

    json.aggs do
      ElasticNewsItem::DUBLIN_CORE_AGG_NAMES.each do |field|
        aggregation(json, field)
      end
    end
  end

  def aggregation(json, field)
    json.set! field do |agg_json|
      agg_json.terms do
        agg_json.field field
        agg_json.size 100
      end
    end
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.child! { json.terms { json.rss_feed_url_id @rss_feed_url_ids } }
          json.child! { published_at_filter(json) } if @since_ts || @until_ts
          json.child! { json.terms { json.tags @tags } } if @tags.present?
        end

        json.must_not do
          json.terms { json.link @excluded_urls }
        end if @excluded_urls.present?
      end
    end
  end

  private

  def feed_url_ids(rss_feeds)
    rss_feeds ||= []
    ids = rss_feeds.flat_map(&:rss_feed_urls).uniq.map(&:id)
    raise ArgumentError, RSS_FEED_URL_REQUIRED if ids.empty?

    ids
  end
end
