# frozen_string_literal: true

class Api::SearchOptions
  include ActiveModel::Validations

  LIMIT_ERROR_MESSAGE_TEMPLATE = 'must be between %s and %s'
  class_attribute :default_limit,
                  :limit_range

  self.default_limit = 20
  self.limit_range = (1..50).freeze

  OFFSET_RANGE = (0..1000).freeze
  DEFAULT_OFFSET = 0
  OFFSET_ERROR_MESSAGE = "must be between #{OFFSET_RANGE.first} and #{OFFSET_RANGE.last}"
  QUERY_PARAMS = %i(query query_not query_or query_quote)

  attr_accessor :access_key,
                :affiliate,
                :enable_highlighting,
                :limit,
                :offset,
                :query,
                :site,
                :query_not,
                :query_quote,
                :query_or,
                :file_type,
                :filter

  validates_presence_of :access_key,
                        :affiliate,
                        message: 'must be present'

  validates_length_of :query,
                      maximum: Search::MAX_QUERYTERM_LENGTH

  validates_inclusion_of :offset,
                         within: OFFSET_RANGE,
                         message: OFFSET_ERROR_MESSAGE

  validate :must_have_valid_limit
  validate :must_have_search_term

  validate :must_have_valid_affiliate,
           :must_have_valid_access_key,
           on: :affiliate

  validates_inclusion_of :filter, in: %w(0 1 2), allow_nil: true

  def self.human_attribute_name(attribute_key_name, _options = {})
    attribute_key_name.to_s
  end

  def initialize(params = {})
    self.access_key = params[:access_key]
    self.affiliate = params[:affiliate]

    self.enable_highlighting = is_highlighting_enabled?(
      params[:enable_highlighting])

    limit = params[:limit]
    self.limit = limit.present? ? limit.to_i : default_limit

    offset = params[:offset]
    self.offset = offset.present? ? offset.to_i : DEFAULT_OFFSET
    self.file_type = params[:filetype]
    self.filter = params[:filter]

    QUERY_PARAMS.each do |param|
      self.send("#{param}=", Sanitizer.sanitize(params[param], encode: false))
    end
  end

  def attributes
    { access_key: access_key,
      affiliate: site,
      enable_highlighting: enable_highlighting,
      limit: limit,
      next_offset_within_limit: next_offset_within_limit?,
      offset: offset,
      query: query,
      query_not: query_not,
      query_quote: query_quote,
      query_or: query_or,
      file_type: file_type,
      filter: filter }
  end

  def next_offset_within_limit?
    limit + offset < OFFSET_RANGE.last
  end

  def site
    @site ||= Affiliate.active.find_by_name(affiliate)
  end

  protected

  def is_highlighting_enabled?(enable_highlighting)
    enable_highlighting.nil? || !(enable_highlighting == 'false')
  end

  def must_have_valid_affiliate
    return unless affiliate.present?
    errors.add(:base, 'affiliate not found') unless site
  end

  def must_have_valid_access_key
    return unless site
    errors.add(:base, 'access_key is invalid') unless site.api_access_key == access_key
  end

  def must_have_valid_limit
    unless limit_range.include? limit
      error_message = LIMIT_ERROR_MESSAGE_TEMPLATE % [limit_range.first, limit_range.last]
      errors.add :limit, error_message
    end
  end

  def must_have_search_term
    unless QUERY_PARAMS.any? { |param| self.send(param).present? }
      errors.add(:base, 'a search term must be present')
    end
  end
end
