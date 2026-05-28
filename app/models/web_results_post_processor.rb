# frozen_string_literal: true

class WebResultsPostProcessor < ResultsPostProcessor
  include ResultsRejector
  SPECIAL_URL_PATH_EXT_NAMES = %w[doc pdf ppt ps rtf swf txt xls docx pptx xlsx].freeze

  attr_reader :results

  def initialize(query, affiliate, results)
    super
    @affiliate = affiliate
    @results = results
    @excluded_urls = @affiliate.excluded_urls_set
  end

  def post_processed_results
    reject_excluded_urls(link_field: :unescaped_url)

    post_processed = @results.collect do |result|
      { 'title' => result.title,
        'content' => result.content,
        'unescapedUrl' => result.unescaped_url }
    end
    post_processed.compact
  end

  def normalized_results(total_results)
    {
      results: format_results,
      total: @affiliate.bing_v7_engine? ? nil : total_results,
      totalPages: total_pages(total_results),
      unboundedResults: @affiliate.bing_v7_engine?
    }
  end

  private

  def format_results
    @results.map do |result|
      {
        title: translate_highlights(result['title']),
        url: result['unescaped_url'],
        fileType: file_type(result['unescaped_url']),
        description: truncate_description(translate_highlights(result['content']))
      }.compact
    end
  end

  def file_type(url)
    return if url.blank?

    ext_name = File.extname(url)[1..]
    ext_name.upcase if SPECIAL_URL_PATH_EXT_NAMES.include?(ext_name&.downcase)
  end
end
