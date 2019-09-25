# frozen_string_literal: true

module ElasticSettings
  KEYWORD = { type: 'keyword',
              normalizer: 'keyword_normalizer' }.freeze

  TEXT = {
    properties: {
      en: {
        type: 'text',
        analyzer: 'en_analyzer',
        copy_to: 'bigram',
        term_vector: 'with_positions_offsets'
      },
      es: {
        type: 'text',
        analyzer: 'es_analyzer',
        copy_to: 'bigram',
        term_vector: 'with_positions_offsets'
      },
      babel: {
        type: 'text',
        analyzer: 'babel_analyzer',
        copy_to: 'bigram',
        term_vector: 'with_positions_offsets'
      }
    }
  }.freeze

  def self.analysis(filename)
    path = Rails.root.join('config', 'locales', 'analysis', filename)
    File.readlines(path).map(&:chomp)
  end

  COMMON = {
    index: {
      analysis: {
        char_filter: {
          ignore_chars: { type: 'mapping',
                          mappings: ["'=>", '’=>', '`=>', 'ʻ=>'] }
        },
        filter: {
          bigram_filter: { type: 'shingle' },
          en_stop_filter: { type: 'stop',
                            stopwords: analysis('en_stopwords.txt') },
          en_synonym: { type: 'synonym',
                        synonyms: analysis('en_synonyms.txt') },
          en_protected_filter: { type: 'keyword_marker',
                                 keywords: analysis('en_protwords.txt') },
          en_stem_filter: { type: 'stemmer',
                            name: 'english' },
          es_stop_filter: { type: 'stop',
                            stopwords: analysis('es_stopwords.txt') },
          es_protected_filter: { type: 'keyword_marker',
                                 keywords: analysis('es_protwords.txt') },
          es_synonym: { type: 'synonym',
                        synonyms: analysis('es_synonyms.txt') },
          es_stem_filter: { type: 'stemmer',
                            name: 'light_spanish' }
        },
        analyzer: {
          babel_analyzer: {
            type: 'custom',
            tokenizer: 'standard',
            filter: %w[asciifolding lowercase]
          },
          default: {
            type: 'custom',
            tokenizer: 'standard',
            filter: %w[asciifolding lowercase]
          },
          en_analyzer: {
            type: 'custom',
            tokenizer: 'standard',
            char_filter: %w[ignore_chars],
            filter: %w[asciifolding
                       lowercase
                       en_stop_filter
                       en_protected_filter
                       en_stem_filter
                       en_synonym]
          },
          es_analyzer: {
            type: 'custom',
            tokenizer: 'standard',
            char_filter: %w[ignore_chars],
            filter: %w[asciifolding
                       lowercase
                       es_stop_filter
                       es_protected_filter
                       es_stem_filter
                       es_synonym]
          },
          bigram_analyzer: {
            type: 'custom',
            tokenizer: 'standard',
            char_filter: %w[ignore_chars],
            filter: %w[asciifolding lowercase bigram_filter]
          }
        },
        normalizer: {
          keyword_normalizer: {
            type: 'custom',
            char_filter: %w[ignore_chars],
            filter: %w[asciifolding lowercase]
          }
        }
      }
    }
  }.freeze
end
