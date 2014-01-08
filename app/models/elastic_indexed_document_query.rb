# coding: utf-8
class ElasticIndexedDocumentQuery < ElasticTextFilteredQuery

  def initialize(options)
    super(options)
    @document_collection = options[:document_collection]
    self.highlighted_fields = %w(title description body)
  end

  def filtered_query_filter(json)
    #TODO: cache these?
    json.filter do
      json.bool do
        json.must do
          json.child! { json.term { json.affiliate_id @affiliate_id } }
        end
        json.set! :should do |should_json|
          @document_collection.url_prefixes.each do |url_prefix|
            should_json.child! { should_json.prefix { json.url url_prefix.prefix } }
          end
        end if @document_collection
      end
    end
  end

  def filtered_query_query(json)
    json.query do
      json.bool do
        json.set! :should do |should_json|
          should_json.child! { multi_match(should_json, highlighted_fields, @q, multi_match_options) }
        end
      end
    end if @q
  end

  def pre_tags
    %w()
  end

  def post_tags
    %w()
  end

  def highlight_fields(json)
    json.fields do
      json.set! :title, { number_of_fragments: 0 }
      json.description
      json.body
    end
  end

end