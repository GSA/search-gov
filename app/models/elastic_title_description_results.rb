# frozen_string_literal: true

class ElasticTitleDescriptionResults < ElasticResults

  def highlight_instance(highlight, instance)
    instance.title = highlight['title'].first if highlight['title']
    instance.description = highlight['description'].join('...') if highlight['description']
    instance
  end

end