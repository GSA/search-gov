# frozen_string_literal: true

require 'typhoeus/adapters/faraday'

module ES
  INDEX_PREFIX = "#{Rails.env}-usasearch"

  def client_reader
    @client_reader ||= initialize_client(reader_config)
  end

  def client_writers
    @client_writers ||= writer_config.map { |config| initialize_client(config) }
  end

  private

  def reader_config
    client_config('reader')
  end

  def writer_config
    client_config('writers')
  end

  def initialize_client(config)
    Elasticsearch::Client.new(config.symbolize_keys)
  end

  module ELK
    extend ES
    private

    def self.client_config(mode)
      Rails.application.secrets['analytics']['elasticsearch'][mode]
    end
  end

  module CustomIndices
    extend ES
    private

    def self.client_config(mode)
      Rails.application.secrets['custom_indices']['elasticsearch'][mode]
    end
  end
end
