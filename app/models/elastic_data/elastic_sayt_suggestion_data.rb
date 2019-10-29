# frozen_string_literal: true

class ElasticSaytSuggestionData
  attr_reader :sayt_suggestion, :language

  def initialize(sayt_suggestion)
    @sayt_suggestion = sayt_suggestion
    @language = sayt_suggestion.affiliate.indexing_locale
  end

  def to_builder
    return if sayt_suggestion.deleted_at.present?

    Jbuilder.new do |json|
      json.(sayt_suggestion, :id, :affiliate_id, :popularity)
      json.set! 'phrase.keyword', sayt_suggestion.phrase
      json.set! "phrase.#{language}", sayt_suggestion.phrase
      json.language language
    end
  end
end
