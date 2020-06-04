class ClickSerp
  include ActiveModel::Validations

  attr_accessor :url, :query, :position, :module_code, :client_ip, :user_agent

  validates :url, :query, :position, :module_code, :client_ip, :user_agent, presence: true

  def initialize(url:,
                 query:,
                 client_ip:,
                 affiliate:,
                 position:,
                 module_code:,
                 vertical:,
                 user_agent:)
    @url = cleaned_url(url)
    @query = query
    @client_ip = client_ip
    @affiliate = affiliate
    @position = position
    @module_code = module_code
    @vertical = vertical
    @user_agent = user_agent
  end

  def log
    Rails.logger.info('[Click] ' + instance_values.to_json)
  end

  private

  def cleaned_url(url)
    CGI.unescape(url).tr(' ', '+') rescue nil
  end
end
