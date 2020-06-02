class ClickApi < ClickSerp
  attr_accessor :affiliate, :access_key

  validates :affiliate, :access_key, presence: true
  validate :valid_access_key

  def initialize(url:, query:, client_ip:, affiliate:, position:, module_code:, vertical:, user_agent:, access_key:)
    @url = url
    @query = query
    @client_ip = client_ip
    @affiliate = affiliate
    @position = position
    @module_code = module_code
    @vertical = vertical
    @user_agent = user_agent
    @access_key = access_key
  end

  private

  def valid_access_key
    if affiliate.present? && access_key.present?
      if Affiliate.find_by(name: affiliate).api_access_key != access_key
        errors.add(:access_key, "is invalid")
      end
    end
  end
end
