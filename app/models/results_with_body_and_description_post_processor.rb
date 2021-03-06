class ResultsWithBodyAndDescriptionPostProcessor
  attr_accessor :results

  def initialize(results)
    @results = results
  end


  def post_process_results
    override_plain_description_with_highlighted_body
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
end
