class I14yPostProcessor < ResultsWithBodyAndDescriptionPostProcessor
  def initialize(results)
    rename_fields(results)
    @results = results
  end

  def rename_fields(results)
    results.each do |result|
      result.body = result.content
      result.link = result.path
      result.published_at = result.created
    end
  end
end
