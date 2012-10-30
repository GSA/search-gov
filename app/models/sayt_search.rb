class SaytSearch
  MIN_RESULTS_COUNT = 5

  def initialize(options)
    @affiliate_id = options[:affiliate_id]
    @locale = options[:locale]
    @query = Misspelling.correct(options[:query])
    @remaining_results = options[:number_of_results] >= MIN_RESULTS_COUNT ? options[:number_of_results] : MIN_RESULTS_COUNT
    @extras = options[:extras]
  end

  def results
    return [] unless @affiliate_id && @query
    @results ||= @extras ? results_with_extras : results_without_extras
  end

  protected
  def results_with_extras
    forms = get_form_results
    @remaining_results -= forms.count
    boosted_contents = get_boosted_content_results
    @remaining_results -= boosted_contents.count

    container = []
    container.push *get_sayt_results_with_section_and_data
    container.push *forms
    container.push *boosted_contents
    container
  end

  def results_without_extras
    SaytSuggestion.fetch_by_affiliate_id(@affiliate_id, @query, @remaining_results).collect(&:phrase)
  end

  def get_form_results
    Form.sayt_for(@affiliate_id, @query, 2).collect do |f|
      { section: I18n.t(:recommended_forms, locale: @locale), label: "#{f.title} (#{f.number})", data: f.landing_page_url }
    end
  end

  def get_boosted_content_results
    BoostedContent.sayt_for(@affiliate_id, @query, 2).collect do |b|
      { section: I18n.t(:recommended_pages, locale: @locale), label: b.title, data: b.url }
    end
  end

  def get_sayt_results_with_section_and_data
    SaytSuggestion.fetch_by_affiliate_id(@affiliate_id, @query, @remaining_results).collect do |s|
      { section: 'default', label: s.phrase }
    end
  end
end
