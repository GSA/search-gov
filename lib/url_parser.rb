require 'addressable/uri'

module UrlParser
  def self.normalize(url)
    url = "http://#{url}" unless url =~ %r{^https?://}i
    normalize_non_query_parts url
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
