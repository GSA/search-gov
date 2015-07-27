module Api::V2::NonCommercialSearch
  include Api::V2::SearchAsJson
  include Api::V2::AsJsonAppendWebSpellingCorrection

  attr_reader :next_offset

  def initialize(options = {})
    super options.merge(Api::V2::HighlightOptions::DEFAULT)
    @next_offset_within_limit = options[:next_offset_within_limit]
  end

  def handle_response(response)
    super
    @next_offset = @offset + @limit if @next_offset_within_limit && more_results_available?
  end

  protected

  def as_json_result_hash(result)
    pub_date = result.published_at ? result.published_at.to_date : nil
    { title: result.title,
      url: result_url(result),
      snippet: as_json_build_snippet(result.description),
      publication_date: pub_date }
  end

  def result_url(result)
    result.url
  end

  def more_results_available?
    @total > (@offset + @limit)
  end
end
