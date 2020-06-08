class ApiClick < Click
  attr_reader :affiliate, :access_key

  validates :affiliate, :access_key, presence: true
  validate :valid_access_key

  def initialize(params)
    super

    @access_key = params[:access_key]
  end

  private

  def valid_access_key
    return unless affiliate.present? && access_key.present?

    affiliate_access_key = Affiliate.find_by(name: affiliate).api_access_key
    errors.add(:access_key, 'is invalid') if affiliate_access_key != access_key
  end
end
