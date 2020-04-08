# frozen_string_literal: true

class RtuCount
  def self.count(index, query_body)
    ES::ELK.client_reader.count(index: index, body: query_body)['count']
  rescue StandardError => error
    Rails.logger.error("Error extracting RtuCount: #{error}")
    nil
  end
end
