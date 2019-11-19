# frozen_string_literal: true

module ElasticSuggest
  def suggest(json)
    json.suggest do
      json.text @q
      json.suggestion do
        json.phrase do
          json.analyzer 'bigram_analyzer'
          json.field 'bigram'
          json.size 1
          json.direct_generator do
            json.child! do
              json.field 'bigram'
              json.prefix_length 1
            end
          end
          json.highlight do
            json.pre_tag pre_tags.first
            json.post_tag post_tags.first
          end
        end
      end
    end
  end
end
