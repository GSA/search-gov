class Click
  include ActiveModel::Validations

  attr_accessor :url, :query, :position, :module_code

  validates :url, :query, :position, :module_code, presence: true

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

  def log
    Rails.logger.info('[Click] ' + self.instance_values.to_json)
  end

  def valid_access_key?
    if @affiliate.present? && @access_key.present?
      Affiliate.find_by(name: @affiliate)&.api_access_key == @access_key
    end
  end
end
