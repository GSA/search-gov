# frozen_string_literal: true

class Click
  include ActiveModel::Validations

  attr_reader :url, :query, :position, :module_code, :client_ip, :user_agent

  validates :url, :query, :position, :module_code, :client_ip, :user_agent, presence: true
  validates :position, numericality: { only_integer: true,
                                       greater_than_or_equal_to: 0,
                                       allow_blank: true }
  validate :client_ip_validation
  validate :module_code_validation

  def initialize(params)
    @url = unescape_url(params[:url])
    @query = params[:query]
    @client_ip = params[:client_ip]
    @affiliate = params[:affiliate]
    @position = params[:position]
    @module_code = params[:module_code]
    @vertical = params[:vertical]
    @user_agent = params[:user_agent]
  end

  def log
    Rails.logger.info('[Click] ' + instance_values.to_json)
  end

  private

  def module_code_validation
    # We use a custom validation here
    # because the built in inclusion validator is compiled
    # before our test fixture data is loaded.
    # https://apidock.com/rails/ActiveModel/Validations/ClassMethods/validates_inclusion_of#427-Check-if-value-is-included-in-array-of-valid-values
    return if module_code.blank?
    return if SearchModule.pluck(:tag).include? module_code

    errors.add(:module_code, "#{module_code} is not a valid module")
  end

  def client_ip_validation
    return if client_ip.blank?
    return if valid_ip?

    errors.add(:client_ip, 'is invalid')
  end

  def valid_ip?
    matched = (client_ip =~ Resolv::AddressRegex)
    matched.present?
  end

  def unescape_url(url)
    CGI.unescape(url).tr(' ', '+')
  rescue StandardError
    nil
  end
end
