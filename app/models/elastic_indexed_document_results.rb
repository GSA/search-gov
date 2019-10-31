# frozen_string_literal: true

class ElasticIndexedDocumentResults < ElasticTitleDescriptionBodyResults
  def spelling_suggestion
    @suggestion ? @suggestion.text : nil
  end
end
