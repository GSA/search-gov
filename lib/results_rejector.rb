module ResultsRejector
  attr_reader :excluded_urls

  private

  def reject_excluded_urls(link_field: :link)
    if excluded_urls.any?
      results.reject!{ |result| url_is_excluded?(result.send(link_field)) }
    end
  end

  def url_is_excluded?(url)
    parsed_url = URI::parse(url) rescue nil
    decoded_url = URI.decode_www_form_component url rescue nil

    return true if parsed_url and excluded_urls.include?(UrlParser.strip_http_protocols(decoded_url))
  rescue
    Rails.logger.info "error stripping protocol for url: #{url}" ; false
  end
end
