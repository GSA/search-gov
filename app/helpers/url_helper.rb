module UrlHelper
  def link_to_url_without_protocol(url, url_options = {})
    if url.present?
      link_to UrlParser.strip_http_protocols(url), url, url_options
    end
  end
end
