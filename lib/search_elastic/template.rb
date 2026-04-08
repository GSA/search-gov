# frozen_string_literal: true


class SearchElastic::Template
  include SearchElastic::Templatable

  LIGHT_STEMMERS = {
    de: 'german',
    es: 'spanish',
    fr: 'french',
    it: 'italian',
    pt: 'portuguese'
  }.freeze

  STANDARD_STEMMERS = {
    bn: 'bengali',
    en: 'english',
    fi: 'finnish',
    hi: 'hindi',
    hu: 'hungarian',
    ru: 'russian',
    sv: 'swedish'
  }.freeze


  LANGUAGE_ANALYZER_LOCALES = [:bn, :de, :en, :es, :fi, :fr, :hi, :hu, :it, :ja, :ko, :pt, :ru, :sv, :zh]
  GENERIC_ANALYZER_LOCALES = LANGUAGE_ANALYZER_LOCALES - [:fr, :ja, :ko, :zh]

  def initialize(index_pattern, shards = 1, replicas = 1)
    @index_pattern = index_pattern
    @shards = shards
    @replicas = replicas
    @synonym_filter_locales = Set.new
    @protected_filter_locales = Set.new
  end

  def body
    Jbuilder.encode do |json|
      json.index_patterns(@index_pattern)
      json.settings do
        json.index do
          json.number_of_shards @shards
          json.number_of_replicas @replicas
        end
        json.analysis do
          char_filter(json)
          filter(json)
          analyzer(json)
          tokenizer(json)
        end
      end
      json.mappings do
        dynamic_templates(json)
        properties(json)
      end
    end
  end

  def char_filter(json)
    json.char_filter do
      json.quotes do
        json.type('mapping')
        json.mappings(['\\u0091=>\\u0027', '\\u0092=>\\u0027', '\\u2018=>\\u0027', '\\u2019=>\\u0027', '\\u201B=>\\u0027'])
      end
    end
  end

  def filter(json)
    json.filter do
      json.bigrams_filter do
        json.type('shingle')
      end
      # language_synonyms(json)
      # language_protwords(json)
      language_stemmers(json)
    end
  end

  def analyzer(json)
    json.analyzer do
      generic_analyzers(json)
      french_analyzer(json)
      japanese_analyzer(json)
      korean_analyzer(json)
      chinese_analyzer(json)
      bigrams_analyzer(json)
      url_path_analyzer(json)
      domain_name_analyzer(json)
      default_analyzer(json)
    end
  end

  def default_analyzer(json)
    json.default do
      json.type('custom')
      json.filter(%w[icu_normalizer icu_folding])
      json.tokenizer('icu_tokenizer')
      json.char_filter(%w[html_strip quotes])
    end
  end

  def domain_name_analyzer(json)
    json.domain_name_analyzer do
      json.type('custom')
      json.filter('lowercase')
      json.tokenizer('domain_name_tokenizer')
    end
  end

  def url_path_analyzer(json)
    json.url_path_analyzer do
      json.type('custom')
      json.filter('lowercase')
      json.tokenizer('url_path_tokenizer')
    end
  end

  def bigrams_analyzer(json)
    json.bigrams_analyzer do
      json.type('custom')
      json.filter(%w[icu_normalizer icu_folding bigrams_filter])
      json.tokenizer('icu_tokenizer')
      json.char_filter(%w[html_strip quotes])
    end
  end

  def generic_analyzers(json)
    GENERIC_ANALYZER_LOCALES.each do |locale|
      generic_analyzer(json, locale)
    end
  end

  def chinese_analyzer(json)
    json.zh_analyzer do
      json.type('custom')
      json.filter(%w[smartcn_word icu_normalizer icu_folding])
      json.tokenizer('smartcn_sentence')
      json.char_filter(['html_strip'])
    end
  end

  def korean_analyzer(json)
    json.ko_analyzer do
      json.type('cjk')
      json.filter([])
    end
  end

  def japanese_analyzer(json)
    json.ja_analyzer do
      json.type('custom')
      json.filter(%w[kuromoji_baseform ja_pos_filter icu_normalizer icu_folding cjk_width])
      json.tokenizer('kuromoji_tokenizer')
      json.char_filter(['html_strip'])
    end
  end

  def french_analyzer(json)
    json.fr_analyzer do
      json.type('custom')
      json.filter(%w[icu_normalizer elision fr_stem_filter icu_folding])
      json.tokenizer('icu_tokenizer')
      json.char_filter(%w[html_strip quotes])
    end
  end

  def tokenizer(json)
    json.tokenizer do
      json.kuromoji do
        json.type('kuromoji_tokenizer')
        json.mode('search')
        json.char_filter(['html_strip'])
      end
      json.url_path_tokenizer do
        json.type('PathHierarchy')
      end
      json.domain_name_tokenizer do
        json.type('PathHierarchy')
        json.delimiter('.')
        json.reverse(true)
      end
    end
  end

  def filter_array(locale)
    array = ['icu_normalizer']
    array << "#{locale}_protected_filter" if @protected_filter_locales.include?(locale)
    array << "#{locale}_stem_filter"
    array << "#{locale}_synonym" if @synonym_filter_locales.include?(locale)
    array << 'icu_folding'
    array
  end

  def properties(json)
    json.properties do
      %w[updated created changed].each { |field| date(json, field) }
      %w[audience content_type document_id extension thumbnail_url language mime_type path
         searchgov_custom1 searchgov_custom2 searchgov_custom3 tags].each { |field| keyword(json, field) }
      basename(json)
      url_path(json)
      domain_name(json)
      promote(json)
      bigrams(json)
      click_count(json)
    end
  end

  def basename(json)
    json.basename do
      json.type('text')
    end
  end

  def bigrams(json)
    json.bigrams do
      json.analyzer('bigrams_analyzer')
      json.type('text')
    end
  end

  def promote(json)
    json.promote do
      json.type('boolean')
    end
  end

  def domain_name(json)
    json.domain_name do
      json.type('text')
      json.analyzer('domain_name_analyzer')
      json.fields do
        json.keyword do
          json.type('keyword')
        end
      end
    end
  end

  def url_path(json)
    json.url_path do
      json.type('text')
      json.analyzer('url_path_analyzer')
    end
  end

  def click_count(json)
    json.click_count do
      json.type('integer')
    end
  end

  def dynamic_templates(json)
    json.dynamic_templates do
      language_templates(json)
      string_fields_template(json, 'text')
    end
  end

  def language_stemmers(json)
    light_stemmers(json)
    standard_stemmers(json)
    japanese_position_filter(json)
  end

  def japanese_position_filter(json)
    json.ja_pos_filter do
      json.type('kuromoji_part_of_speech')
      json.stoptags(['\\u52a9\\u8a5e-\\u683c\\u52a9\\u8a5e-\\u4e00\\u822c', '\\u52a9\\u8a5e-\\u7d42\\u52a9\\u8a5e'])
    end
  end

  def light_stemmers(json)
    LIGHT_STEMMERS.each do |locale, language|
      generic_stemmer(json, locale, language, 'light')
    end
  end

  def standard_stemmers(json)
    STANDARD_STEMMERS.each do |locale, language|
      generic_stemmer(json, locale, language, 'standard')
    end
  end

  def language_templates(json)
    LANGUAGE_ANALYZER_LOCALES.each do |locale|
      json.child! do
        json.set!(locale) do
          json.match("*_#{locale}")
          json.match_mapping_type('string')
          json.mapping do
            json.analyzer("#{locale}_analyzer")
            json.type('text')
            json.term_vector('with_positions_offsets')
            json.copy_to('bigrams')
          end
        end
      end
    end
  end

  def language_synonyms(json)
    parse_configuration_file(json, 'synonyms')
  end

  def language_protwords(json)
    parse_configuration_file(json, 'protwords')
  end

  def synonyms_filter(json, locale, lines)
    @synonym_filter_locales.add(locale)
    linguistic_filter(json, locale, lines, 'synonym', 'synonyms', 'synonym')
  end

  def protwords_filter(json, locale, lines)
    @protected_filter_locales.add(locale)
    linguistic_filter(json, locale, lines, 'protected_filter', 'keywords', 'keyword_marker')
  end
end
