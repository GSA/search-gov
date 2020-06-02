class ClickSerp
  include ActiveModel::Validations

  attr_accessor :url, :query, :position, :module_code

  validates :url, :query, :position, :module_code, presence: true

  def initialize(url:, query:, client_ip:, affiliate:, position:, module_code:, vertical:, user_agent:)
    @url = url
    @query = query
    @client_ip = client_ip
    @affiliate = affiliate
    @position = position
    @module_code = module_code
    @vertical = vertical
    @user_agent = user_agent
  end

  def log
    Rails.logger.info('[Click] ' + self.instance_values.to_json)
  end
end
