class ClickApi < ClickSerp
  attr_reader :affiliate, :access_key

  validates :affiliate, :access_key, presence: true
  validate :valid_access_key

  def initialize(params)
    @url = cleaned_url(params[:url])
    @query = params[:query]
    @client_ip = params[:client_ip]
    @affiliate = params[:affiliate]
    @position = params[:position]
    @module_code = params[:module_code]
    @vertical = params[:vertical]
    @user_agent = params[:user_agent]
    @access_key = params[:access_key]
  end

  private

  def valid_access_key
    return unless affiliate.present? && access_key.present?

    if Affiliate.find_by(name: affiliate).api_access_key != access_key
      errors.add(:access_key, 'is invalid')
    end
  end
end
