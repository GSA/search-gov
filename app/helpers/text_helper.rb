module TextHelper
  def url_without_protocol(url)
    url.gsub(%r[^https?://]i, '') if url.present?
  end
end
