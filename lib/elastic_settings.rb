module ElasticSettings
  KEYWORD = { type: 'string', analyzer: 'case_insensitive_keyword_analyzer' }
  SPANISH_STOPWORDS = %w(a al ante aquel aquello bajo cabe cada como con conmigo consigo contigo contra cual cuando de del desde despues donde durante e el en entonces entre es esta esto fin fue ha hacia has hasta la las le les los mas mediante menos mi ni o para pero por que quien salvo segun ser si sin so sobre solamente solo somos son soy su suya suyo suyos tal tambien tras u un una unas unos via y)
  ENGLISH_STOPWORDS = %w(a an and are as at be but by for if in into is no not of on or s such t that the their then there these they this to was with)

  COMMON = {
    index: {
      analysis: {
        char_filter: {
          ignore_chars: { type: "mapping", mappings: ["'=>", "’=>", "`=>"] }
        },
        filter: {
          en_stop_filter: { type: "stop", stopwords: ENGLISH_STOPWORDS },
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
