require 'addressable/uri'

module UrlParser
  def self.normalize(url)
    url = "http://#{url}" unless %r{^https?://}i.match?(url)
    normalize_non_query_parts(url)
  end

  def self.mime_type(url)
    case url
    when /\.(gif)$/i
      'image/gif'
    when /\.(jpg|jpeg|jpe|jif|jfif|jfi)$/i
      'image/jpeg'
    when /\.(png)$/i
      'image/png'
    end
  end

  def self.strip_http_protocols(url)
    url.sub(%r{^https?://}i, '') if url.present?
  end

  def self.normalize_host(url)
    Addressable::URI.parse(url).normalized_host
  rescue
    nil
  end

  def self.update_scheme(url, scheme)
    uri = URI(url)
    uri.scheme = scheme
    uri.to_s
  end

  def self.redact_query(url)
    return url unless url&.match?(/(&|\?)query=/)

    uri = Addressable::URI.parse(url)
    query_values = uri.query_values
    query_values['query'] = Redactor.redact(query_values['query'])
    uri.query_values = query_values
    uri.to_s
  end

  def self.normalize_non_query_parts(uri)
    addressable_uri = Addressable::URI.parse(uri)
    addressable_uri.host = addressable_uri.normalized_host
    addressable_uri.authority = addressable_uri.normalized_authority
    addressable_uri.path = addressable_uri.normalized_path.squeeze('/')
    addressable_uri.fragment = nil
    addressable_uri.to_s
  rescue
    nil
  end
end
