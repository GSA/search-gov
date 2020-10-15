# frozen_string_literal: true

class Click
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_accessor :url

  attr_reader :affiliate, :query, :position,
              :module_code, :client_ip, :user_agent, :vertical, :referrer

  before_validation :unescape_url

  validates :query, :position, :module_code, :client_ip, :user_agent, :url, presence: true
  validates :position, numericality: { only_integer: true,
                                       greater_than_or_equal_to: 0,
                                       allow_blank: true }
  validates :client_ip, format: { with: Resolv::AddressRegex,
                                  allow_blank: true,
                                  message: 'is invalid' }
  validate  :module_code_validation
  validates :url, url: { message: 'is not a valid format', allow_blank: true }

  def initialize(params)
    @url = params[:url]
    @query = params[:query]
    @client_ip = params[:client_ip]
    @affiliate = params[:affiliate]
    @position = params[:position]
    @module_code = params[:module_code]
    @vertical = params[:vertical]
    @user_agent = params[:user_agent]
    @referrer = params[:referrer]
  end

  def log
    Rails.logger.info('[Click] ' + click_hash.to_json)
  end

  private

  def unescape_url
    return unless url

    unescaped_url = CGI.unescape(url)
    self.url = unescaped_url.valid_encoding? ? unescaped_url : 'invalid URL'
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

  # This hash is used in click logging for consumption by Logstash. Any changes
  # to this hash or to the log line may require corresponding changes to our Logstash
  # template or config in the cookbooks.
  def click_hash
    {
      clientip: client_ip,
      referrer: referrer,
      user_agent: user_agent,
      time: Time.current.to_formatted_s(:db),
      vertical: vertical,
      modules: module_code,
      click_domain: URI(url).host,
      params: {
        url: url,
        affiliate: affiliate,
        query: query.downcase,
        position: position
      }
    }
  end
end
