module ElasticTitleDescriptionBodyHighlightFields
  def highlight_fields(json)
    json.fields do
      json.set! :title, { number_of_fragments: 0 }
      json.set! :description, { fragment_size: 75, number_of_fragments: 2 }
      json.set! :body, { fragment_size: 75, number_of_fragments: 2 }
    end
  end

  def default_pre_tags
    %w()
  end

  def default_post_tags
    %w()
  end

end
