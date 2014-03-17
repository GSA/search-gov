module ElasticSettings
  KEYWORD = { type: 'string', analyzer: 'case_insensitive_keyword_analyzer' }
  SPANISH_STOPWORDS = %w(a al ante bajo cabe con conmigo contigo consigo contra de del desde durante e el en entre hacia hasta la las los mediante ni o para pero por según sin so sobre tras un una unas unos vía y u salvo son es ser soy somos como si esto esta está has ha  tal que quien mi suya suyo suyos entonces después le les su más menos cual cuando donde también cada aquel aquello fin fue solo solamente)

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
          es_stop_filter: { type: "stop", stopwords: SPANISH_STOPWORDS },
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
