# frozen_string_literal: true

class ResultsPostProcessor
  MAX_PAGES = 500
  DEFAULT_TRUNCATED_HTML_LENGTH = 280
  DEFAULT_TRUNCATE_OPTIONS = { length_in_chars: true, ellipsis: ' ...' }.freeze

  def initialize(*args); end

  def total_pages(total_results)
    pages = total_results.to_i / 20
    pages += 1 if (total_results.to_i % 20).positive?
    return MAX_PAGES if pages >= MAX_PAGES

    pages
  rescue
    0
  end

  def translate_highlights(body)
    return if body.nil?

    body.gsub(/\uE000/, '<strong>').gsub(/\uE001/, '</strong>')
  end

  def truncate_description(html)
    return '' unless html

    HTML_Truncator.truncate(html, DEFAULT_TRUNCATED_HTML_LENGTH, DEFAULT_TRUNCATE_OPTIONS)
  end

  def rss_module(news_results)
    news_results.map do |news_item|
      {
        title: news_item.title,
        url: news_item.link,
        publishedAt: news_item.published_at
      }
    end
  end
end
