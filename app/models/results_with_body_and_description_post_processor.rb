# frozen_string_literal: true

class ResultsWithBodyAndDescriptionPostProcessor < ResultsPostProcessor
  include NewsItemsHelper
  attr_accessor :results

  SPECIAL_URL_PATH_EXT_NAMES = %w[doc pdf ppt ps rtf swf txt xls docx pptx xlsx].freeze

  def initialize(results, _val: nil, youtube: false)
    super
    @results = results
    @youtube = youtube
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
        publishedAt: news_item_time_ago_in_words(result['published_at']),
        fileType: file_type(result['url']),
        youtube: @youtube,
        youtubePublishedAt: (result&.published_at if @youtube),
        youtubeThumbnailUrl: (result&.youtube_thumbnail_url if @youtube),
        youtubeDuration: (result&.duration if @youtube),
        blendedModule: result_module_for_blended(result)
      }.compact_blank
    end
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
    return unless search_class == 'IndexedDocument' || 'NewsItem'

    BlendedSearch::KLASS_MODULE_MAPPING[search_class.underscore.to_sym]
  end
end
