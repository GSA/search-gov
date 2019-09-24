# frozen_string_literal: true

module ElasticTitleDescriptionBodyHighlightFields
  def highlight_fields(json)
    json.fields do
      json.set! "title.#{language}", { number_of_fragments: 0 }
      json.set! "description.#{language}", { fragment_size: 75, number_of_fragments: 2 }
      json.set! "body.#{language}", { fragment_size: 75, number_of_fragments: 2 }
    end
  end

  def default_pre_tags
    ['']
  end

  def default_post_tags
    ['']
  end
end
