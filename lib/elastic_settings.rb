module ElasticSettings
  COMMON = {
    index: {
      analysis: {
        char_filter: {
          ignore_chars: { type: "mapping", mappings: ["'=>", "’=>", "`=>"] }
        },
        filter: {
          en_stop_filter: { type: "stop", stopwords: ["_english_"] },
          en_synonym: { type: 'synonym', synonyms: File.readlines(Rails.root.join("config", "locales", "analysis", "en_synonyms.txt")) },
          en_stem_filter: { type: "stemmer", name: "minimal_english" },
          es_stop_filter: { type: "stop", stopwords: ["_spanish_"] },
          es_synonym: { type: 'synonym', synonyms: File.readlines(Rails.root.join("config", "locales", "analysis", "es_synonyms.txt")) },
          es_stem_filter: { type: "stemmer", name: "light_spanish" }
        },
        analyzer: {
          en_analyzer: {
            type: "custom",
            tokenizer: "standard",
            char_filter: %w(ignore_chars),
            filter: %w(standard asciifolding lowercase en_stop_filter en_stem_filter en_synonym) },
          es_analyzer: {
            type: "custom",
            tokenizer: "standard",
            char_filter: %w(ignore_chars),
            filter: %w(standard asciifolding lowercase es_stop_filter es_stem_filter es_synonym) },
          case_insensitive_keyword_analyzer: {
            tokenizer: 'keyword',
            char_filter: %w(ignore_chars),
            filter: %w(standard asciifolding lowercase) } } } }
  }.freeze

end
