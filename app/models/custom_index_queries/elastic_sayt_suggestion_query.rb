# frozen_string_literal: true

class ElasticSaytSuggestionQuery < ElasticTextFilteredQuery
  def initialize(options)
    super(options.merge(sort: 'popularity:desc'))
    @affiliate_id = options[:affiliate_id]
    @text_fields = ['phrase']
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.term { json.affiliate_id @affiliate_id }
        end
        json.must_not do
          json.term do
            json.set! 'phrase.keyword', @q.downcase
          end
        end
      end
    end
  end
end
