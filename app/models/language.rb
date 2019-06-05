class Language < ApplicationRecord
  validates_presence_of :code, :name
  validates_uniqueness_of :code, case_sensitive: false
  has_many :affiliates, foreign_key: :locale, primary_key: :code

  def self.bing_market_for_code(code)
    language = find_by_code(code)

    if language && language.is_azure_supported && language.inferred_country_code
      "#{code}-#{language.inferred_country_code}"
    else
      'en-US'
    end
  end
end
