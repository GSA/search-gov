require 'addressable/uri'

module UrlParser
  def self.normalize(url)
    url = "http://#{url}" unless url =~ /^https?:\/\//i
    uri = Addressable::URI.parse(URI.parse(url)) rescue nil
    return nil unless uri
    uri.host = uri.normalized_host
    uri.authority = uri.normalized_authority
    uri.path = uri.normalized_path
    uri.fragment = nil
    uri.to_s
  end
end
