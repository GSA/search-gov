module Searches::FiltersHelper
  def results_count_html(search)
    return if search.results.blank?

    content_tag(:li, id: 'results-count') do
      count = search.total
      result_count_str = I18n.t(:'searches.results_count',
                                count: count,
                                formatted_count: number_with_delimiter(count))
      content_tag(:span, result_count_str)
    end
  end
end
