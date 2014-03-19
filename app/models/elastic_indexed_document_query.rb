class ElasticIndexedDocumentQuery < ElasticTextFilteredQuery

  def initialize(options)
    super(options)
    @affiliate_id = options[:affiliate_id]
    @document_collection = options[:document_collection]
    self.highlighted_fields = %w(title description body)
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.term { json.affiliate_id @affiliate_id }
        end
        json.set! :should do |should_json|
          @document_collection.url_prefixes.each do |url_prefix|
            should_json.child! { should_json.prefix { json.url url_prefix.prefix } }
          end
        end if @document_collection
      end
    end
  end

  def highlight_fields(json)
    json.fields do
      json.set! :title, { number_of_fragments: 0 }
      json.set! :description, {fragment_size: 75, number_of_fragments: 2}
      json.set! :body, {fragment_size: 75, number_of_fragments: 2}
    end
  end

  def pre_tags
    %w()
  end

  def post_tags
    %w()
  end

end