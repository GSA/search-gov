# frozen_string_literal: true

class Language < ApplicationRecord
  validates :code, :name, presence: true

  validates :code, uniqueness: { case_sensitive: false }

  has_many :affiliates, foreign_key: :locale, primary_key: :code, inverse_of: :language

  def self.bing_market_for_code(code)
    language = find_by(code: code)

    if language&.inferred_country_code
      "#{code}-#{language.inferred_country_code}"
    else
      'en-US'
    end
  end

  def self.iso_639_1(language)
    return unless language

    language.downcase[/^(?<code>[a-z]{2})(-|\z)/, 'code'] ||
      Language.find_by(name: language)&.code
  end
end
