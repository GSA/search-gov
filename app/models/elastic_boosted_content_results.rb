class ElasticBoostedContentResults < ElasticResults

  def highlight_instance(highlight, instance)
    if highlight.present? and instance.present?
      instance.title = highlight['title'].first if highlight['title']
      instance.description = highlight['description'].first if highlight['description']
    end
    instance
  end

end