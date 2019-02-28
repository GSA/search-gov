# frozen_string_literal: true

module ElasticSettings
  KEYWORD = { type: 'text',
              analyzer: 'case_insensitive_keyword_analyzer' }.freeze

  COMMON = {
    index: {
      analysis: {
        char_filter: {
          ignore_chars: { type: "mapping", mappings: ["'=>", "’=>", "`=>", "ʻ=>"] }
        },
        filter: {
          bigram_filter: { type: 'shingle' },
          en_stop_filter: { type: "stop", stopwords: File.readlines(Rails.root.join("config", "locales", "analysis", "en_stopwords.txt")) },
          en_synonym: { type: 'synonym', synonyms: File.readlines(Rails.root.join("config", "locales", "analysis", "en_synonyms.txt")).map(&:chomp) },
          en_protected_filter: { type: 'keyword_marker', keywords: File.readlines(Rails.root.join("config", "locales", "analysis", "en_protwords.txt")).map(&:chomp) },
          en_stem_filter: { type: "stemmer", name: "english" },
          es_stop_filter: { type: "stop", stopwords: File.readlines(Rails.root.join("config", "locales", "analysis", "es_stopwords.txt")).map(&:chomp) },
          es_protected_filter: { type: 'keyword_marker', keywords: File.readlines(Rails.root.join("config", "locales", "analysis", "es_protwords.txt")).map(&:chomp) },
          es_synonym: { type: 'synonym', synonyms: File.readlines(Rails.root.join("config", "locales", "analysis", "es_synonyms.txt")).map(&:chomp) },
          es_stem_filter: { type: "stemmer", name: "light_spanish" }
        },
        analyzer: {
          babel_analyzer: {
            type: "custom",
            tokenizer: "standard",
            filter: %w(standard asciifolding lowercase) },
          en_analyzer: {
            type: "custom",
            tokenizer: "standard",
            char_filter: %w(ignore_chars),
            filter: %w(standard asciifolding lowercase en_stop_filter en_protected_filter en_stem_filter en_synonym) },
          es_analyzer: {
            type: "custom",
            tokenizer: "standard",
            char_filter: %w(ignore_chars),
            filter: %w(standard asciifolding lowercase es_stop_filter es_protected_filter es_stem_filter es_synonym) },
          bigram_analyzer: {
            type: "custom",
            tokenizer: "standard",
            char_filter: %w(ignore_chars),
            filter: %w(standard asciifolding lowercase bigram_filter)
          },
          case_insensitive_keyword_analyzer: {
            tokenizer: 'keyword',
            char_filter: %w(ignore_chars),
            filter: %w(standard asciifolding lowercase) } } } }
  }.freeze

end
