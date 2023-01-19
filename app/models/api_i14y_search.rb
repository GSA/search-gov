# frozen_string_literal: true

class ApiI14ySearch < I14ySearch
  include Api::V2::NonCommercialSearch

  protected

  def result_url(result)
    result.link
  end

  def as_json_result_hash(result)
    if @include_facets
      super.merge(add_facets_to_results(result))
    else
      super
    end
  end

  def add_facets_to_results(result)
    fields = {}
    I14ySearch::FACET_FIELDS.each do |field|
      next if result[field].nil?

      process_facet_fields(fields, field.to_sym, result)
    end

    fields
  end

  def process_facet_fields(fields, field, result)
    if field == :changed
      fields[:updated_date] = result['changed'].to_date
    else
      fields[field] = result[field.to_s]
    end
  end
end
