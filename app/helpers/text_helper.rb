module TextHelper
  DEFAULT_URL_TRUNCATION_LENGTH = 65.freeze

  def url_without_protocol(url)
    url.gsub(%r[^https?://]i, '') if url.present?
  end

  def truncate_url(url, truncation_length = DEFAULT_URL_TRUNCATION_LENGTH)
    Truncator::UrlParser.shorten_url(url, truncation_length)
  end
end
