# frozen_string_literal: true

class Click
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_reader :affiliate, :url, :query, :position,
              :module_code, :client_ip, :user_agent, :vertical

  validates :url, :query, :position, :module_code, :client_ip, :user_agent, presence: true
  validates :url, url: { allow_blank: true, message: 'is not a valid format' }
  validates :position, numericality: { only_integer: true,
                                       greater_than_or_equal_to: 0,
                                       allow_blank: true }
  validates :client_ip, format: { with: Resolv::AddressRegex,
                                  allow_blank: true,
                                  message: 'is invalid' }
  validate :url_validation, :module_code_validation

  after_validation :unescape_url

  def initialize(params)
    @url = params[:url]
    @query = params[:query]
    @client_ip = params[:client_ip]
    @affiliate = params[:affiliate]
    @position = params[:position]
    @module_code = params[:module_code]
    @vertical = params[:vertical]
    @user_agent = params[:user_agent]
  end

  def log
    Rails.logger.info('[Click] ' + click_hash.to_json)
  end

  private

  def url_validation
    return if url.blank?
    return if CGI.unescape(url).valid_encoding?

    errors.add(:url, 'is not a valid format')
  end

  def module_code_validation
    # We use a custom validation here
    # because the built in inclusion validator is compiled
    # before our test fixture data is loaded.
    # https://apidock.com/rails/ActiveModel/Validations/ClassMethods/validates_inclusion_of#427-Check-if-value-is-included-in-array-of-valid-values
    return if module_code.blank?
    return if SearchModule.pluck(:tag).include? module_code

    errors.add(:module_code, "#{module_code} is not a valid module")
  end

  def unescape_url
    return if url.blank?
    return unless errors.empty?

    @url = CGI.unescape(url).tr(' ', '+')
  end

  def click_hash
    {
      url: url,
      query: query,
      client_ip: client_ip,
      affiliate: affiliate,
      position: position,
      module_code: module_code,
      vertical: vertical,
      user_agent: user_agent
    }
  end
end
