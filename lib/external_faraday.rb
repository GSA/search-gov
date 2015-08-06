require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

module ExternalFaraday
  CONFIG = YAML.load_file(Rails.root.join('config/external_faraday.yml')).freeze

  def self.configure_connection(ns, conn)
    config = get_config ns
    config['options'].each { |key, value| conn.options.send(:"#{key}=", value) }
    conn.adapter config['adapter']
  end

  def self.get_config(ns)
    CONFIG[Rails.env][ns] || CONFIG[Rails.env]
  end
end
