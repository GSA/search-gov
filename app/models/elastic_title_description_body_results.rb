# frozen_string_literal: true

class ElasticTitleDescriptionBodyResults < ElasticResults

  def highlight_instance(highlight, instance)
    instance.title = highlight['title'].first if highlight['title']
    instance.description = highlight['description'].join('...') if highlight['description']
    instance.body = highlight['body'].join('...') if highlight['body']
    instance
  end

end
