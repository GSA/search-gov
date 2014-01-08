class ElasticIndexedDocumentResults < ElasticResults

  def highlight_instance(highlight, instance)
    if highlight.present? and instance.present?
      instance.title = highlight['title'].first if highlight['title']
      instance.description = highlight['description'].join('...') if highlight['description']
      instance.body = highlight['body'].join('...') if highlight['body']
    end
    instance
  end

end