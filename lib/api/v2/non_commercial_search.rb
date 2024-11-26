# frozen_string_literal: true

module Api::V2::NonCommercialSearch
  include Api::V2::SearchAsJson
  include Api::V2::AsJsonAppendWebSpellingCorrection

  # attr_reader :next_offset

  # def initialize(options = {})
  #   super
  # end

  protected

  def result_url(result)
    result.url
  end
end
