# frozen_string_literal: true

class ElasticBlendedQuery < ElasticTextFilterByPublishedAtQuery
  include ElasticSuggest
  include ElasticTitleDescriptionBodyHighlightFields
  include ElasticQueryStringQuery

  def initialize(options)
    super(options)
    @affiliate_id = options[:affiliate_id]
    @rss_feed_url_ids = options[:rss_feed_url_ids]
    @text_fields = %w[title description body]
  end

  def body
    Jbuilder.encode do |json|
      indices_boost(json)
      query(json)
      highlight(json) if @highlighting
      suggest(json)
    end
  end

  def query(json)
    json.query do
      json.function_score do
        super(json)
        json.functions do
          json.child! do
            json.gauss do
              json.published_at do
                json.scale '28d'
              end
            end
          end
          json.child! do
            json.field_value_factor do
              json.field 'popularity'
            end
          end
        end unless @sort
      end
    end
  end

  def indices_boost(json)
    #TODO: use aliases when https://github.com/elasticsearch/elasticsearch/issues/4756 is fixed
    index_names = ES::CustomIndices.client_reader.indices.get_alias(name: ElasticBlended.reader_alias.join(',')).keys.sort
    json.indices_boost do
      index_names.each_with_index do |index_name, idx|
        json.set! index_name, ElasticBlended::INDEX_BOOSTS[idx]
      end
    end
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.child! { published_at_filter(json) }
        end if @since_ts || @until_ts
        json.set! :should do |json|
          json.child! { json.term { json.affiliate_id @affiliate_id } }
          json.child! { json.terms { json.rss_feed_url_id @rss_feed_url_ids } }
        end
      end
    end
  end
end
