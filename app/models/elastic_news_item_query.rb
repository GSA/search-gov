class ElasticNewsItemQuery < ElasticTextFilteredQuery
  DUBLIN_CORE_AGG_NAMES = [:contributor, :subject, :publisher]

  def initialize(options)
    options[:sort] = '_score' if options[:sort_by_relevance]
    super({ sort: 'published_at:desc' }.merge(options))
    @rss_feed_url_ids = feed_url_ids(options[:rss_feeds])
    @since_ts = options[:since]
    @until_ts = options[:until]
    @excluded_urls = options[:excluded_urls].try(:collect, &:url)
    @tags = options[:tags]
    @dublin_core_aggs = options.slice(*DUBLIN_CORE_AGG_NAMES).delete_if { |agg_name, agg_value| agg_value.nil? }
    self.highlighted_fields = %w(title description)
  end

  def query(json)
    filtered_query(json)

    json.post_filter do
      json.and do
        @dublin_core_aggs.each do |facet, value|
          json.child! { json.term { json.set! facet, value } }
        end
      end
    end if @dublin_core_aggs.present?

    json.aggs do
      DUBLIN_CORE_AGG_NAMES.each do |field|
        aggregation(json, field)
      end
    end
  end

  def aggregation(json, field)
    json.set! field do |agg_json|
      agg_json.terms { agg_json.field field }
    end
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.child! { json.terms { json.rss_feed_url_id @rss_feed_url_ids } }
          json.child! { published_at_filter(json) } if @since_ts or @until_ts
          json.child! { json.terms { json.tags @tags } } if @tags.present?
        end

        json.must_not do
          json.terms { json.link @excluded_urls }
        end if @excluded_urls.present?
      end
    end
  end

  def published_at_filter(json)
    json.range do
      json.published_at do
        json.gt @since_ts if @since_ts
        json.lt @until_ts if @until_ts
      end
    end
  end

  def highlight_fields(json)
    json.fields do
      json.set! :title, { number_of_fragments: 0 }
      json.set! :description, {fragment_size: 75, number_of_fragments: 2}
    end
  end

  def pre_tags
    %w()
  end

  def post_tags
    %w()
  end

  private

  def feed_url_ids(rss_feeds)
    rss_feeds ||= []
    ids = rss_feeds.flat_map(&:rss_feed_urls).uniq.map(&:id)
    raise ArgumentError.new("NewsItem query requires at least one RSS feed URL to be present") if ids.empty?
    ids
  end

end