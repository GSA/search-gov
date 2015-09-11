class ElasticSaytSuggestionData

  def initialize(sayt_suggestion)
    @sayt_suggestion = sayt_suggestion
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@sayt_suggestion, :id, :affiliate_id, :phrase, :popularity)
      json.language "#{@sayt_suggestion.affiliate.indexing_locale}_analyzer"
    end unless @sayt_suggestion.deleted_at.present?
  end

end