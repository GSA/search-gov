# frozen_string_literal: true

class Language < ActiveRecord::Base
  validates :code, :name, presence: true

  validates_uniqueness_of :code, case_sensitive: false

  has_many :affiliates, foreign_key: :locale, primary_key: :code, inverse_of: :language

  def self.bing_market_for_code(code)
    language = find_by_code(code)

    if language && language.is_azure_supported && language.inferred_country_code
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
