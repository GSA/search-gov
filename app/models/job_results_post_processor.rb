class JobResultsPostProcessor
  attr_reader :results

  def initialize(results:)
    @results = results.map(&:matched_object_descriptor)
  end

  def post_processed_results
    results.each do |result|
      result.id = result.position_id
      result.url = result.position_uri
      result.locations = result.position_location.map(&:location_name)
      result.minimum = result.position_remuneration.first.minimum_range.to_f
      result.maximum = result.position_remuneration.first.maximum_range.to_f
      result.rate_interval_code = result.position_remuneration.first.rate_interval_code
    end
  end
end
