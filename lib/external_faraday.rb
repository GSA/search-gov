require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

module ExternalFaraday
  CONFIG = Rails.application.config_for(:external_faraday)

  def self.configure_connection(ns, conn)
    config = get_config ns
    config['options'].each { |key, value| conn.options.send(:"#{key}=", value) }
    conn.adapter config['adapter']
  end

  def self.get_config(ns)
    CONFIG[ns] || CONFIG
  end
end
