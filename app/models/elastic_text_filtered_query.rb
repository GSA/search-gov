class ElasticTextFilteredQuery < ElasticQuery
  MIN_SIMILARITY = 0.80

  def initialize(options)
    super(options)
    @affiliate_id = options[:affiliate_id]
    @text_analyzer = "#{options[:language]}_analyzer"
  end

  def query(json)
    json.query do
      json.filtered do
        filtered_query_query(json)
        filtered_query_filter(json)
      end
    end
  end

  def multi_match_options
    { operator: :and, analyzer: @text_analyzer, fuzziness: MIN_SIMILARITY, prefix_length: 2 }
  end

end