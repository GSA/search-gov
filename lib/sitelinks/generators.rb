module Sitelinks
  module Generators
    extend ActiveSupport::Concern

    included do
      class_eval do
        class_attribute :url_prefix, instance_writer: false
      end
    end

    module ClassMethods
      def url_prefix_overlap?(urls)
        sanitized_urls = urls.map { |url| UrlParser.strip_http_protocols(url) }
        sanitized_urls.detect { |url| UrlCoverage.overlap?(url, url_prefix) }
      end
    end

    def self.registered
      @@registered ||= begin
        Dir[Rails.root.join('lib/sitelinks/generators/*.rb')].collect do |path|
          class_name = path.split('/').last.split('.').first.camelize
          "#{self.name}::#{class_name}".constantize
        end
      end
    end

    def self.matching_generator_names(urls)
      Sitelinks::Generators.registered.map do |generator|
        generator.name if generator.url_prefix_overlap? urls
      end.compact
    end

    def self.classes_by_names(names)
      return [] unless names.present?
      names.collect do |name|
        name.constantize rescue nil
      end.compact
    end
  end
end
