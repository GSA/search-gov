# frozen_string_literal: true

class ApiSearchElastic < SearchElasticEngine
  include ApiSearch

  def as_json_result_hash(result)
    super.merge(thumbnail_url: result.thumbnail_url)
  end
end
