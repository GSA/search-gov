class ElasticFederalRegisterDocumentQuery < ElasticTextFilteredQuery
  def initialize(options)
    super(options)
    self.highlighted_fields = %w(abstract title)
    @federal_register_agency_ids = options[:federal_register_agency_ids]
  end

  def query(json)
    json.query do
      json.function_score do
        super(json)
        json.functions do
          json.child! do
            json.gauss do
              json.comments_close_on do
                json.origin Date.current.yesterday.to_s(:db)
                json.scale '4w'
              end
            end
          end
        end
        json.boost_mode 'replace'
      end
    end
  end

  def filtered_query_query(json)
    json.query do
      json.bool do
        json.set! :should do |should_json|
          should_json.child! { should_json.terms { should_json.document_number @q.split(/\s+/) } }
          should_json.child! { multi_match(should_json, highlighted_fields, @q, multi_match_options) }
        end
      end
    end if @q.present?
  end

  def multi_match_options
    { operator: :and, analyzer: @text_analyzer }
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.child! { json.terms { json.federal_register_agency_ids @federal_register_agency_ids } }
        end
      end
    end
  end
end
