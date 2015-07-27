class I14yPostProcessor < ResultsWithBodyAndDescriptionPostProcessor
  def initialize(enable_highlighting, results)
    @enable_highlighting = enable_highlighting
    rename_fields(results)
    @results = results
  end

  def post_process_results
    super
    strip_highlighting unless @enable_highlighting
  end

  protected

  def strip_highlighting
    @results.each do |result|
      result.body = StringProcessor.strip_highlights result.body
      result.description = StringProcessor.strip_highlights result.description
      result.title = StringProcessor.strip_highlights result.title
    end
  end

  def rename_fields(results)
    results.each do |result|
      result.body = result.content
      result.link = result.path
      result.published_at = result.created
    end
  end
end
