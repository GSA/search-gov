class ClickSerp
  include ActiveModel::Validations

  attr_reader :url, :query, :position, :module_code, :client_ip, :user_agent

  validates :url, :query, :position, :module_code, :client_ip, :user_agent, presence: true

  def initialize(params)
    @url = cleaned_url(params[:url])
    @query = params[:query]
    @client_ip = params[:client_ip]
    @affiliate = params[:affiliate]
    @position = params[:position]
    @module_code = params[:module_code]
    @vertical = params[:vertical]
    @user_agent = params[:user_agent]
  end

  def log
    Rails.logger.info('[Click] ' + self.to_json)
  end

  private

  def cleaned_url(url)
    CGI.unescape(url).tr(' ', '+') rescue nil
  end
end
