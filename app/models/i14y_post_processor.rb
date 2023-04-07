class I14yPostProcessor < ResultsWithBodyAndDescriptionPostProcessor
  include ResultsRejector

  def initialize(enable_highlighting, results, excluded_urls=[])
    @enable_highlighting = enable_highlighting
    @results = results
    rename_fields
    @excluded_urls = excluded_urls
  end

  def post_process_results
    super
    reject_excluded_urls
    strip_highlighting unless @enable_highlighting
  end

  def normalized_results
    @results.map do |result|
      {
        title: result['title'],
        url: result['link'],
        description: result['body']
      }
    end
  end

  protected

  def override_plain_description_with_highlighted_body
    results.each do |result|
      description = []
      description << result.description if highlighted?(result.description)
      description << result.body if highlighted?(result.body)
      result.description = description.join('...')
    end
  end

  def strip_highlighting
    results.each do |result|
      result.body = StringProcessor.strip_highlights result.body
      result.description = StringProcessor.strip_highlights result.description
      result.title = StringProcessor.strip_highlights result.title
    end
  end

  def rename_fields
    results.each do |result|
      result.body = result.content
      result.link = result.path
      result.published_at = result.created
    end
  end
end
