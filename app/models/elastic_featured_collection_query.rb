class ElasticFeaturedCollectionQuery < ElasticQuery
  MIN_SIMILARITY = 0.80

  def initialize(options)
    super(options)
    @affiliate_id = options[:affiliate_id]
    self.highlighted_fields = %w(title link_titles)
    @text_analyzer = "#{options[:language]}_analyzer"
  end

  def query(json)
    json.query do
      json.filtered do
        featured_collection_query(json)
        featured_collection_filter(json)
      end
    end
  end

  def featured_collection_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.child! { json.term { json.status :active } }
          json.child! { json.term { json.affiliate_id @affiliate_id } }
          filter_field_on_current_date(json, :publish_start_on, :lte)
          filter_field_on_current_date(json, :publish_end_on, :gt)
        end
      end
    end
  end

  def featured_collection_query(json)
    json.query do
      json.bool do
        json.set! :should do |should_json|
          should_json.child! { should_json.match { should_json.keyword_values @q } }
          should_json.child! { multi_match(should_json, highlighted_fields, @q, multi_match_options) }
        end
      end
    end if @q
  end

  def filter_field_on_current_date(json, field, operator)
    json.child! do
      json.range do
        json.set! field do
          json.set! operator, Date.current
        end
      end
    end
  end

  def multi_match_options
    { operator: :and, analyzer: @text_analyzer, fuzziness: MIN_SIMILARITY, prefix_length: 2 }
  end

end