class Api::BlendedSearchOptions < Api::SearchOptions

  attr_accessor :sort_by

  def initialize(params = {})
    super
    self.sort_by = params[:sort_by]
  end

  def attributes
    { access_key: access_key,
      affiliate: site,
      highlighting: enable_highlighting,
      limit: limit,
      next_offset_within_limit: next_offset_within_limit?,
      offset: offset,
      query: query,
      sort_by: sort_by }
  end
end
