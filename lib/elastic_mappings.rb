# frozen_string_literal: true

module ElasticMappings
  COMMON = {
    dynamic: :strict,
    properties: {
      language: { type: 'keyword', index: true },
      id: { type: 'integer' },
      bigram: { type: 'text', analyzer: 'bigram_analyzer' }
    }
  }.freeze

  BEST_BET = COMMON.deep_merge(
    properties: {
      affiliate_id: { type: 'integer' },
      status: { type: 'keyword', index: true },
      publish_start_on: { type: 'date', format: 'YYYY-MM-dd' },
      publish_end_on: { type: 'date', format: 'YYYY-MM-dd', null_value: '9999-12-31' },
      title: ElasticSettings::TEXT,
      match_keyword_values_only: { type: 'boolean',
                                   null_value: 'false' },
      keyword_values: ElasticSettings::KEYWORD
    }
  ).freeze
end
