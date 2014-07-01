class ElasticFederalRegisterDocumentResults < ElasticResults

  def highlight_instance(highlight, instance)
    instance.title = highlight['title'].first if highlight['title']
    instance
  end

end
