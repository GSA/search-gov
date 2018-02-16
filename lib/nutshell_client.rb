class NutshellClient
  CONFIG = Rails.application.config_for(:nutshell).freeze

  HOST = 'https://app01.nutshell.com'.freeze
  ENDPOINT = '/api/v1/json'.freeze

  def self.enabled?
    CONFIG['username'].present? && CONFIG['password'].present?
  end

  def post(method_sym, params)
    body = build_body method_sym, params
    notification_name = "#{self.class.name.tableize.singularize}.usasearch"
    ActiveSupport::Notifications.instrument(notification_name, query: { term: body }) do
      response = connection.post ENDPOINT, body
      process_response response
    end
  end

  def connection
    @@connection ||= NutshellApiConnection.new
  end

  def request_id
    Digest::MD5.hexdigest("#{Time.current.to_i}:#{rand}").slice(0..8)
  end

  private

  def build_body(method_sym, params)
    { id: request_id,
      jsonrpc: '2.0',
      method: method_sym.to_s.camelize(:lower),
      params: params }
  end

  def process_response(response)
    is_success = response.status == 200
    Rails.logger.error("Nutshell API error status: #{response.status} body: #{response.body}") unless is_success
    [is_success, response.body]
  end

  class NutshellApiConnection
    extend Forwardable
    def_delegator :@connection, :post

    def initialize
      @connection = Faraday.new HOST do |conn|
        conn.basic_auth CONFIG['username'], CONFIG['password']
        conn.request :json
        conn.response :mrashify
        conn.response :json
        conn.adapter :net_http_persistent
      end
    end
  end
end
