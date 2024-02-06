# frozen_string_literal: true

class Api::CommercialSearchOptions < Api::SearchOptions
  validates_presence_of :api_key, message: 'must be present'

  def initialize(params = {})
    super
    @api_key = params[:api_key]
  end

  def attributes
    super.merge(api_key: api_key)
  end

  attr_reader :api_key
end
