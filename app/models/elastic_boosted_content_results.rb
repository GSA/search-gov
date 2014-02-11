class ElasticBoostedContentResults < ElasticResults

  def highlight_instance(highlight, instance)
    instance.title = highlight['title'].first if highlight['title']
    instance.description = highlight['description'].first if highlight['description']
    instance
  end

end