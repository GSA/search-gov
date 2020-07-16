# frozen_string_literal: true

module Sanitizer
  def self.sanitize(str, decode = true)
    Loofah.fragment(str).scrub!(:prune).text(encode_special_chars: decode).squish
  rescue ArgumentError => e
    Rails.logger.error("Error sanitizing string #{str}: #{e}")
    nil
  end
end
