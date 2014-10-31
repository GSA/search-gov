require 'sitelink_generator'

module SitelinkGeneratorUtils
  def self.matching_generator_names(urls)
    SitelinkGenerator::GENERATORS.map do |generator|
      generator.name if url_prefix_overlap? generator.url_prefix, urls
    end.compact
  end

  def self.url_prefix_overlap?(url_prefix, urls)
    sanitized_urls = urls.map { |url| UrlParser.strip_http_protocols(url) }
    sanitized_urls.detect { |url| UrlCoverage.overlap?(url, url_prefix) }
  end

  def self.classes_by_names(names)
    return [] unless names.present?
    names.collect do |name|
      SitelinkGenerator::GENERATOR_HASH[name]
    end.compact
  end
end
