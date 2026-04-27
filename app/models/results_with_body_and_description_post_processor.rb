# frozen_string_literal: true

class ResultsWithBodyAndDescriptionPostProcessor < ResultsPostProcessor
  include ActionView::Helpers::DateHelper

  attr_accessor :results

  SPECIAL_URL_PATH_EXT_NAMES = %w[doc pdf ppt ps rtf swf txt xls docx pptx xlsx].freeze

  def initialize(results, _val: nil, youtube: false)
    super
    @results = results
  end

  def post_process_results
    override_plain_description_with_highlighted_body
  end

  def normalized_results(total_results)
    {
      results: format_results,
      total: total_results,
      totalPages: total_pages(total_results),
      unboundedResults: false
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
        title: translate_highlights(result['title']),
        url: result['url'] || result['link'],
        description: format_description(result),
        publishedAt: format_published_at(result['published_at']),
        fileType: file_type(result['url']),
        blendedModule: result_module_for_blended(result)
      }.compact_blank
    end
  end

  def format_published_at(published_at)
    return unless published_at.present? && published_at < Time.current

    time_ago_in_words(published_at, scope: 'datetime.time_ago_in_words')
  end

  def format_description(result)
    truncate_description(translate_highlights(result['description'] || result['body']))
  end

  def file_type(url)
    return if url.blank?

    ext_name = File.extname(url)[1..]
    ext_name.upcase if SPECIAL_URL_PATH_EXT_NAMES.include?(ext_name&.downcase)
  end

  def result_module_for_blended(result)
    search_class = result.class.name
    return unless %w[IndexedDocument NewsItem].include?(search_class)

    BlendedSearch::KLASS_MODULE_MAPPING[search_class.underscore.to_sym]
  end
end
