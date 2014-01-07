class ElasticBoostedContentResults < ElasticResults

  def extract_results(hits)
    ids = hits.collect { |hit| hit['_id'] }
    instances = BoostedContent.where(id: ids).includes(:boosted_content_keywords)
    instance_hash = Hash[instances.map { |instance| [instance.id, instance] }]
    hits.map { |hit| highlight_instance(hit['highlight'], instance_hash[hit['_id'].to_i]) }.compact
  end

  private

  def highlight_instance(highlight, instance)
    if highlight.present? and instance.present?
      instance.title = highlight['title'].first if highlight['title']
      instance.description = highlight['description'].first if highlight['description']
    end
    instance
  end

end