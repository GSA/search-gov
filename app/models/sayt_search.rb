class SaytSearch
  attr_accessor :affiliate_id, :extras, :number_of_results, :remaining_results, :query

  def initialize(query, number_of_results)
    self.query = query
    number_of_results = 0 if self.query.blank?
    self.number_of_results = self.remaining_results = number_of_results
  end

  def query=(new_query)
    @query = Misspelling.correct(new_query)
  end

  def results
    return [] unless affiliate_id
    extras ? results_with_extras : results_without_extras
  end

  protected
  def results_with_extras
    @results ||= [].tap do |results|
      # We fetch sayt_results last so that the other results will reduce
      # the remaining results. We then add sayt_results to the front of the
      # array because that's the order in the Pivotal story, silly.
      forms = get_form_results
      boosted_content = get_boosted_content_results
      results.push *get_sayt_results_with_section_and_data
      results.push *forms
      results.push *boosted_content
    end
  end

  def results_without_extras
    @results ||= get_sayt_results_as_array
  end

  def get_boosted_content_results
    fetch(data: :url, label: :title, section: 'Recommended Pages') do
      BoostedContent.sayt_for(query, affiliate_id, 2)
    end
  end

  def get_form_results
    form_agency_ids = FormAgency.joins(:affiliates).where('affiliates.id = ?', affiliate_id).select('form_agencies.id').collect(&:id)
    return if form_agency_ids.empty?
    fetch(data: :landing_page_url, label: :title_and_number, section: 'Recommended Forms') do
      Form.has_landing_page.verified.sayt_for(form_agency_ids, query, 2)
    end
  end

  def get_sayt_results_as_array
    SaytSuggestion.fetch_by_affiliate_id(affiliate_id, query, remaining_results).collect(&:phrase)
  end

  def get_sayt_results_with_section_and_data
    fetch(label: :phrase, section: 'default') do
      SaytSuggestion.fetch_by_affiliate_id(affiliate_id, query, remaining_results)
    end
  end

  private
  # Fetch repeats some common logic on adding results. It lazily evaluates a block
  # that should return search results, but only if conditions are perfect.
  # Once it's done that, it maps results against a field_map of
  # "resulting hash key" => "method to call on result"
  def fetch(field_map, &block)
    return [] unless remaining_results > 0
    results = Array(instance_eval(&block))
    self.remaining_results -= results.length
    results.map do |result|
      {
        data: field_map[:data] && result.send(field_map[:data]),
        label: result.send(field_map[:label]),
        section: field_map[:section]
      }
    end
  end
end
