class ApiBlendedSearch < BlendedSearch
  def initialize(options = {})
    super

    @highlight_options[:pre_tags]  ||= Api::V2::HighlightOptions::DEFAULT[:pre_tags]
    @highlight_options[:post_tags] ||= Api::V2::HighlightOptions::DEFAULT[:post_tags]
  end

  def result_url(result)
    result.url
  end
end
