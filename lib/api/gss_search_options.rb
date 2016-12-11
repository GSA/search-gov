class Api::GssSearchOptions < Api::CommercialSearchOptions
  attr_accessor :cx
  attr_reader :api_key

  self.default_limit = 10
  self.limit_range = (1..10).freeze

  validates_presence_of :cx,
                        message: 'must be present'

  def initialize(params = {})
    super
    self.cx = params[:cx]
  end

  def attributes
    super.merge(cx: cx)
  end
end
