class Api::CommercialSearchOptions < Api::SearchOptions
  attr_accessor :api_key

  validates_presence_of :api_key,
                        message: 'must be present'

  def initialize(params = {})
    super
    self.api_key = params[:api_key]
  end

  def attributes
    super.merge(api_key: api_key)
  end
end
