class Api::BlendedSearchOptions < Api::SearchOptions
  def attributes
    { access_key: access_key,
      affiliate: site,
      highlighting: enable_highlighting,
      limit: limit,
      next_offset_within_limit: next_offset_within_limit?,
      offset: offset,
      query: query }
  end
end
