class SaytSearch
  attr_accessor :affiliate, :number_of_results, :remaining_results, :query

  def initialize(query, number_of_results)
    self.query = query
    number_of_results = 0 if self.query.empty?
    self.number_of_results = self.remaining_results = number_of_results
  end

  def query=(new_query)
    @query = new_query.to_s.gsub('\\', '').squish
  end

  def results
    @results ||= [].tap do |results|
      # We fetch sayt_results last so that the other results will reduce
      # the remaining results. We then add sayt_results to the front of the
      # array because that's the order in the Pivotal story, silly.
      forms = get_form_results
      boosted_content = get_boosted_content_results
      results.push *get_sayt_results
      results.push *forms
      results.push *boosted_content
    end
  end

  protected
  def get_boosted_content_results
    return unless affiliate
    fetch(data: :url, label: :title, section: 'Recommendations') do
      BoostedContent.search_for(query, affiliate, 1, 2).results
    end
  end

  def get_form_results
    fetch(data: :url, label: :title, section: 'Forms') do
      Form.search_for(query, :count => 2).results
    end
  end

  def get_sayt_results
    return unless affiliate
    fetch(label: :phrase, section: 'default', priority: 0) do
      SaytSuggestion.fetch_by_affiliate_id(affiliate.id, query, remaining_results)
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
