class ElasticSaytSuggestionResults < ElasticResults

  def highlight_instance(highlight, instance)
    instance.phrase = highlight['phrase'].first if highlight['phrase']
    instance
  end

end