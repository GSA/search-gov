class Api::DocsSearchOptions < Api::CommercialSearchOptions
  attr_accessor :dc

  validates_presence_of :dc,
                        message: 'must be present'

  def initialize(params = {})
    super
    self.dc = params[:dc]
  end

  def attributes
    super.merge({dc: dc})
  end
end
