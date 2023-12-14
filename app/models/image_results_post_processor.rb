# frozen_string_literal: true

class ImageResultsPostProcessor < ResultsPostProcessor
  SPECIAL_URL_PATH_EXT_NAMES = %w[doc pdf ppt ps rtf swf txt xls docx pptx xlsx].freeze

  def initialize(total_results, results)
    super
    @total_results = total_results
    @results = results
  end

  def normalized_results
    {
      results: format_results,
      total: @total_results,
      totalPages: total_pages(@total_results),
      unboundedResults: false
    }
  end

  private

  def format_results
    @results&.map do |result|
      {
        altText: result['title'],
        url: result['url'],
        thumbnailUrl: result['thumbnail']['url'],
        image: true,
        fileType: file_type(result['url'])
      }.compact
    end
  end

  def file_type(url)
    return if url.blank?

    ext_name = File.extname(url)[1..]
    ext_name.upcase if SPECIAL_URL_PATH_EXT_NAMES.include?(ext_name&.downcase)
  end
end
