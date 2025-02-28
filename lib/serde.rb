# frozen_string_literal: true

module Serde
  LANGUAGE_FIELDS = %i[title description content].freeze

  def self.serialize_hash(hash, language)
    serialize_language(hash, language)
    hash.merge!(uri_params_hash(hash[:path])) if hash[:path].present?
    serialize_array_fields(hash)
    serialize_string_fields(hash)
    hash[:updated_at] = Time.now.utc
    hash
  end

  def self.serialize_language(hash, language)
    LANGUAGE_FIELDS.each do |key|
      value = hash[key.to_sym]
      next if value.blank?

      sanitized_value = Loofah.fragment(value).text(encode_special_chars: false).squish
      hash.store("#{key}_#{language}", sanitized_value)
      hash.delete(key)
    end
  end

  def self.serialize_array_fields(hash)
    %i[searchgov_custom1 searchgov_custom2 searchgov_custom3 tags].each do |field|
      next if hash[field].is_a?(Array)

      hash[field] = hash[field].extract_array if hash[field].present?
    end
  end

  def self.serialize_string_fields(hash)
    %i[audience content_type].each do |field|
      hash[field] = hash[field].downcase if hash[field].present?
    end
  end

  def self.deserialize_hash(hash, language)
    derivative_language_fields = LANGUAGE_FIELDS.collect { |key| "#{key}_#{language}" }
    (derivative_language_fields & hash.keys).each do |field|
      hash[field.chomp("_#{language}")] = hash.delete(field)
    end
    misc_fields = %w[basename extension url_path domain_name bigrams]

    hash.except(*misc_fields)
  end

  def self.uri_params_hash(path)
    hash = {}
    uri = URI.parse(path)
    hash[:basename] = File.basename(uri.path, '.*')
    hash[:extension] = File.extname(uri.path).sub(/^./, '').downcase
    hash[:url_path] = uri.path
    hash[:domain_name] = uri.host
    hash
  end
end
