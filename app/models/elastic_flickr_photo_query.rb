class ElasticFlickrPhotoQuery < ElasticTextFilteredQuery

  def initialize(options)
    super(options)
    @affiliate_id = options[:affiliate_id]
    self.highlighted_fields = %w(title description)
  end

  def filtered_query_filter(json)
    json.filter do
      json.term { json.affiliate_id @affiliate_id }
    end
  end

  def filtered_query_query(json)
    json.query do
      json.bool do
        json.set! :should do |should_json|
          should_json.child! { should_json.match { should_json.tags @q } }
          should_json.child! { multi_match(should_json, highlighted_fields, @q, multi_match_options) }
        end
      end
    end if @q.present?
  end

  def highlight_fields(json)
    json.fields do
      json.set! :title, { number_of_fragments: 0 }
      json.set! :description, {fragment_size: 75, number_of_fragments: 2}
    end
  end

  def multi_match_options
    { operator: :and, analyzer: @text_analyzer }
  end

end