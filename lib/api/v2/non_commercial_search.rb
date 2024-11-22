# frozen_string_literal: true

module Api::V2::NonCommercialSearch
  include Api::V2::SearchAsJson
  include Api::V2::AsJsonAppendWebSpellingCorrection

  attr_reader :next_offset

  def initialize(options = {})
    super
    @next_offset_within_limit = options[:next_offset_within_limit]
  end

  def handle_response(response)
    super
    @next_offset = @offset + @limit if @next_offset_within_limit && more_results_available?
  end

  protected

  def result_url(result)
    result.url
  end

  def more_results_available?
    @total > (@offset + @limit)
  end
end
