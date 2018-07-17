require 'addressable/uri'

module UrlParser
  def self.normalize(url)
    url = "http://#{url}" unless url =~ %r{^https?://}i
    normalize_non_query_parts url
  end

  def self.mime_type(url)
    case url
      when /\.(gif)$/i then
        'image/gif'
      when /\.(jpg|jpeg|jpe|jif|jfif|jfi)$/i then
        'image/jpeg'
      when /\.(png)$/i then
        'image/png'
    end
  end

  def self.strip_http_protocols(url)
    url.sub(%r[^https?://]i, '') if url.present?
  end

  def self.normalize_host(url)
    Addressable::URI.parse(url).normalized_host rescue nil
  end

  def self.update_scheme(url, scheme)
    uri = URI(url)
    uri.scheme = scheme
    uri.to_s
  end

  private

  def self.normalize_non_query_parts(uri)
    addressable_uri = Addressable::URI.parse uri rescue nil
    addressable_uri.host = addressable_uri.normalized_host
    addressable_uri.authority = addressable_uri.normalized_authority
    addressable_uri.path = addressable_uri.normalized_path.gsub(/\/+/, '/')
    addressable_uri.fragment = nil
    addressable_uri.to_s
  rescue
    nil
  end
end
