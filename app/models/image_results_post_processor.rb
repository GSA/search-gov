# frozen_string_literal: true

class ImageResultsPostProcessor < ResultsPostProcessor
  def initialize(total_results, results)
    super
    @total_results = total_results
    @results = results
  end

  def normalized_results
    {
      totalPages: total_pages(@total_results),
      results: format_results,
      unboundedResults: false
    }
  end

  private

  def format_results
    @results&.map do |result|
      {
        altText: result['title'],
        url: result['url'],
        thumbnailUrl: result['thumbnail']['url']
      }
    end
  end
end
