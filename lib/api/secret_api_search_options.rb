class Api::SecretApiSearchOptions < Api::SearchOptions
  attr_accessor :sc_access_key

  validates_presence_of :sc_access_key,
                        message: 'must be present'

  validate :must_have_valid_secret_access_key

  def initialize(params = {})
    super
    self.sc_access_key = params[:sc_access_key]
    self.limit = params[:limit] || 10
  end

  def must_have_valid_secret_access_key
    return unless sc_access_key
    errors.add(:hidden_key, 'is required') unless sc_access_key == SC_ACCESS_KEY
  end
end
