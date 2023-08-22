# frozen_string_literal: true

class ResultsWithBodyAndDescriptionPostProcessor < ResultsPostProcessor
  attr_accessor :results

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
      totalPages: total_pages(total_results),
      results: format_results,
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
        youtube: @youtube,
        youtubePublishedAt: (result&.published_at if @youtube),
        youtubeThumbnailUrl: (result&.youtube_thumbnail_url if @youtube),
        youtubeDuration: (result&.duration if @youtube)
      }.compact_blank
    end
  end

  def format_description(result)
    truncate_description(translate_highlights(result['description'] || result['body']))
  end
end
