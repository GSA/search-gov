module ExternalFaraday
  CONFIG = YAML.load_file(Rails.root.join('config/external_faraday.yml'))[Rails.env].freeze

  def self.set_connection_options(conn)
    CONFIG.each { |key, value| conn.options.send(:"#{key}=", value) }
  end
end
