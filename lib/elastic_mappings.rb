module ElasticMappings
  COMMON = {
    dynamic: :strict,
    properties: {
      language: { type: 'keyword', index: true },
      affiliate_id: { type: 'integer' },
      id: { type: 'integer' } }
  }.freeze

  BEST_BET = COMMON.deep_merge(
    properties: {
      status: { type: 'keyword', index: true },
      publish_start_on: { type: 'date', format: 'YYYY-MM-dd' },
      publish_end_on: { type: 'date', format: 'YYYY-MM-dd', null_value: '9999-12-31' },
      title: { type: 'text', term_vector: 'with_positions_offsets' },
      match_keyword_values_only: { type: 'boolean',
                                   index: :not_analyzed,
                                   null_value: 'false' },
      keyword_values: ElasticSettings::KEYWORD }
  ).freeze

end
