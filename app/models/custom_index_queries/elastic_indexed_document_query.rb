# frozen_string_literal: true

class ElasticIndexedDocumentQuery < ElasticTextFilteredQuery
  include ElasticSuggest
  include ElasticTitleDescriptionBodyHighlightFields
  include ElasticQueryStringQuery

  def initialize(options)
    super(options)
    @affiliate_id = options[:affiliate_id]
    @document_collection = options[:document_collection]
    @include_suggestion = options[:include_suggestion]
    @text_fields = %w[title description body]
  end

  def body
    super do |json|
      suggest(json) if @include_suggestion
    end
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
end
