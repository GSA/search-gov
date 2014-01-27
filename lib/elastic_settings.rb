module ElasticSettings
  ES_SYNONYMS = ["visa, vis"]
  EN_SYNONYMS = [
    'sequestered, sequestration => sequester',
    'bomber, bombed, bombing => bomb',
    'fracturing, fracking, hydrofracking, hydrofracturing'
  ]
  COMMON = {
    index: {
      analysis: {
        filter: {
          es_synonym: { type: 'synonym', synonyms: ES_SYNONYMS },
          en_synonym: { type: 'synonym', synonyms: EN_SYNONYMS },
          en_stop_filter: { type: "stop", stopwords: ["_english_"] },
          en_stem_filter: { type: "stemmer", name: "minimal_english" },
          es_stop_filter: { type: "stop", stopwords: ["_spanish_"] },
          es_stem_filter: { type: "stemmer", name: "light_spanish" }
        },
        analyzer: {
          en_analyzer: {
            type: "custom",
            tokenizer: "standard",
            filter: %w(standard asciifolding lowercase en_stop_filter en_stem_filter en_synonym) },
          es_analyzer: {
            type: "custom",
            tokenizer: "standard",
            filter: %w(standard asciifolding lowercase es_stop_filter es_stem_filter es_synonym) },
          case_insensitive_keyword_analyzer: {
            tokenizer: 'keyword',
            filter: %w(standard asciifolding lowercase) } } } }
  }.freeze

end
