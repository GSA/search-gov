# frozen_string_literal: true

class ElasticFederalRegisterDocumentQuery < ElasticTextFilteredQuery
  def initialize(options)
    super(options.merge(sort: 'comments_close_on:desc'))
    @text_fields = %w[abstract title]
    @text_analyzer = 'en_analyzer'
    @federal_register_agency_ids = options[:federal_register_agency_ids]
  end

  def body
    Jbuilder.encode do |json|
      query json
      aggs json
    end
  end

  def aggs(json)
    json.aggs do
      json.group_ids do
        json.terms do
          json.field :group_id
          json.order { json.top_hit :desc }
        end
        json.aggs do
          top_tag_hits json
          top_hit json
        end
      end
    end
  end

  def top_tag_hits(json)
    json.top_tag_hits do
      json.top_hits do
        json.set! :sort do |sort_json|
          sort_json.child! { sort_json.publication_date { sort_json.order :desc } }
        end
        json._source false
        json.size 1
        highlight(json) if @highlighting
      end
    end
  end

  def top_hit(json)
    json.top_hit do
      json.max do
        json.field :comments_close_on
      end
    end
  end

  def filtered_query_query(json)
    return if @q.blank?

    json.must do
      json.bool do
        json.set! :should do |should_json|
          should_json.child! do
            should_json.terms { should_json.document_number @q.split(/\s+/) }
          end
          should_json.child! do
            multi_match(should_json, highlighted_fields, @q, multi_match_options)
          end
        end
      end
    end
  end

  def multi_match_options
    { operator: :and, analyzer: @text_analyzer }
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.child! do
            json.terms do
              json.federal_register_agency_ids @federal_register_agency_ids
            end
          end
        end
        json.set! :should do
          json.child! { json.term { json.document_type 'rule' } }
          json.child! { json.term { json.significant true } }
          json.child! do
            json.range do
              json.publication_date do
                json.gte 'now-90d/d'
              end
            end
          end
          json.child! do
            json.range do
              json.comments_close_on do
                json.gte 'now/d'
              end
            end
          end
        end
      end
    end
  end
end
