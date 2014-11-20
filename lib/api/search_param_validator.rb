class Api::SearchParamValidator
  ACCESS_KEY_ERROR = 'access_key must be present'.freeze

  LIMIT_RANGE = (1..50).freeze
  DEFAULT_LIMIT = 20
  LIMIT_ERROR = "limit must be between #{LIMIT_RANGE.first} and #{LIMIT_RANGE.last}".freeze

  OFFSET_RANGE = (0..1000).freeze
  DEFAULT_OFFSET = 0
  OFFSET_ERROR = "offset must be between #{OFFSET_RANGE.first} and #{OFFSET_RANGE.last}".freeze

  QUERY_ERROR = 'query must be present'.freeze
  attr_reader :errors

  def initialize(search_params)
    @errors = []

    @access_key = search_params[:access_key]

    @enable_highlighting = is_highlighting_enabled?(
      search_params[:enable_highlighting])

    limit = search_params[:limit]
    @limit = limit.present? ? limit.to_i : DEFAULT_LIMIT

    offset = search_params[:offset]
    @offset = offset.present? ? offset.to_i : DEFAULT_OFFSET

    @query = Sanitize.clean(search_params[:query].to_s).
      gsub(/[[:space:]]/, ' ').squish
  end

  def valid?
    validate_access_key
    validate_limit
    validate_offset
    validate_query
    @errors.blank?
  end

  def valid_params
    { highlighting: @enable_highlighting,
      limit: @limit,
      offset: @offset,
      query: @query }
  end

  private

  def is_highlighting_enabled?(enable_highlighting_param)
    enable_highlighting_param.nil? || !(enable_highlighting_param == 'false')
  end

  def validate_access_key
    @errors << ACCESS_KEY_ERROR unless @access_key.present?
  end

  def validate_limit
    @errors << LIMIT_ERROR unless LIMIT_RANGE.include? @limit
  end

  def validate_offset
    @errors << OFFSET_ERROR unless OFFSET_RANGE.include? @offset
  end

  def validate_query
    @errors << QUERY_ERROR unless @query.present?
  end
end
