module ElasticMappings
  COMMON = {
    dynamic: :strict,
    _analyzer: { path: "language" },
    properties: {
      language: { type: "string", index: :not_analyzed },
      affiliate_id: { type: 'integer' },
      id: { type: 'integer', index: :not_analyzed }
    }
  }.freeze

  BEST_BET = COMMON.deep_merge(
    properties: {
      status: { type: 'string', index: :not_analyzed },
      publish_start_on: { type: 'date', format: 'YYYY-MM-dd' },
      publish_end_on: { type: 'date', format: 'YYYY-MM-dd', null_value: '9999-12-31' },
      title: { type: 'string', term_vector: 'with_positions_offsets' },
      match_keyword_values_only: { type: 'boolean',
                                   index: :not_analyzed,
                                   null_value: 'false' },
      keyword_values: ElasticSettings::KEYWORD }
  ).freeze

end
