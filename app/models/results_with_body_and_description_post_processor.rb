class ResultsWithBodyAndDescriptionPostProcessor < ResultsPostProcessor
  attr_accessor :results

  def initialize(results)
    super
    @results = results
  end

  def post_process_results
    override_plain_description_with_highlighted_body
  end

  def normalized_results(total_results)
    {
      totalPages: total_pages(total_results),
      results: format_results,
      bing: false
    }
  end

  protected

  def override_plain_description_with_highlighted_body
    results.each do |result|
      result.description = result.body if !result.description? || result_body_highlighted?(result)
    end
  end

  def result_body_highlighted?(result)
    !highlighted?(result.description) and highlighted?(result.body)
  end

  def highlighted?(field)
    field =~ /\uE000/
  end

  private

  def format_results
    @results.map do |result|
      {
        title: result['title'],
        url: result['url'],
        description: result['description'] || result['body'],
        updatedDate: nil,
        publishedDate: nil,
        thumbnailUrl: nil
      }
    end
  end
end
