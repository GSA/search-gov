# frozen_string_literal: true

module SearchElastic::Templatable
  def date(json, field)
    json.set! field do
      json.type "date"
    end
  end

  def keyword(json, field)
    json.set! field do
      json.type "keyword"
      json.index true
    end
  end

  def string_fields_template(json, type)
    json.child! do
      json.string_fields do
        json.mapping do
          json.type type
          json.index true
        end
        json.match_mapping_type "string"
        json.match "*"
      end
    end
  end

  def linguistic_filter(json, locale, lines, name, field, type)
    json.set! "#{locale}_#{name}" do
      json.type type
      json.set! field, lines
    end
  end

  def parse_configuration_file(json, type)
    LANGUAGE_ANALYZER_LOCALES.map do |locale|
      [locale, Rails.root.join("config", "locales", "analysis", "#{locale}_#{type}.txt")]
    end.select do |locale_file_array|
      File.exist? locale_file_array.last
    end.each do |locale, file|
      lines = get_lines_from(file)
      send("#{type}_filter", json, locale, lines) if lines.any?
    end
  end

  def get_lines_from(file)
    File.readlines(file).map(&:chomp).reject { |line| line.starts_with?("#") }
  end

  def generic_stemmer(json, locale, language, degree)
    json.set! "#{locale}_stem_filter" do
      json.type "stemmer"
      stemmer_name = degree == "standard" ? '' : "#{degree}_"
      json.name "#{stemmer_name}#{language}"
    end
  end

  def generic_analyzer(json, locale)
    json.set! "#{locale}_analyzer" do
      json.type "custom"
      json.filter filter_array(locale)
      json.tokenizer "icu_tokenizer"
      json.char_filter ["html_strip", "quotes"]
    end
  end
end
