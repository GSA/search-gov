module Searches::FiltersHelper
  TIME_FILTER_KEYS = (['all'] + FilterableSearch::TIME_BASED_SEARCH_OPTIONS.keys).freeze

  def search_filters_and_results_count(search, search_params)
    return unless search.is_a? FilterableSearch

    html = [results_count_html(search)]
    # This yicky conditional is (hopefully) a temporary hack until we have more
    # consistent date info for Search.gov docs and improved date sorting/date display:
    # https://www.pivotaltracker.com/story/show/158572324
    # https://www.pivotaltracker.com/story/show/158571861
    if !(search.affiliate.search_engine == 'SearchGov' && search.class == I14ySearch)
      html << refine_search_html
      html << time_filter_html(search, search_params)
      html << sort_filter_html(search, search_params)
      html << clear_button_html(search, search_params)
    end

    render partial: 'searches/filters_and_results_count', locals: { html: html.join("\n") }
  end

  def time_filter_html(search, search_params)
    current_time_filter_key = extract_current_time_filter_key search

    html = TIME_FILTER_KEYS.collect do |time_filter_key|
      time_filter_list_item search,
                            search_params,
                            current_time_filter_key,
                            time_filter_key
    end.compact

    html << content_tag(:li) do
      link_to I18n.t(:custom_range), '#custom-date-search-form-modal',
              data: { target: '#custom-date-search-form-modal', toggle: 'modal' },
              id: 'custom-date-range-filter-trigger'
    end

    dropdown_filter_wrapper html.join("\n"),
                            'time-filter-dropdown',
                            current_time_filter_description(search)
  end

  def extract_current_time_filter_key(search)
    if search.tbs
      search.tbs
    elsif search.since || search.until
      'custom'
    else
      'all'
    end
  end

  def time_filter_list_item(search, search_params, current_time_filter_key, time_filter_key)
    return if current_time_filter_key == time_filter_key

    time_filter_description = time_filter_description_by_key time_filter_key

    if FilterableSearch::TIME_BASED_SEARCH_OPTIONS[time_filter_key]
      time_params = { since_date: nil,
                      tbs: time_filter_key,
                      until_date: nil }
    else
      time_params = { since_date: nil,
                      tbs: nil,
                      until_date: nil }
    end
    path = path_for_filterable_search search,
                                      search_params,
                                      time_params

    content_tag(:li) { link_to time_filter_description, path }
  end

  def time_filter_description_by_key(time_filter_key)
    case time_filter_key
    when 'all'
      I18n.t :all_time
    else
      I18n.t "last_#{FilterableSearch::TIME_BASED_SEARCH_OPTIONS[time_filter_key]}"
    end
  end

  def sort_filter_html(search, search_params)
    filter_options = build_sort_filter_options search.sort_by_relevance?
    path = path_for_filterable_search search,
                                      search_params,
                                      filter_options[:extra_params]
    html = content_tag :li do
      link_to filter_options[:other_option], path
    end

    dropdown_filter_wrapper html,
                            'sort-filter-dropdown',
                            filter_options[:current_option]
  end

  def build_sort_filter_options(is_sort_by_relevance)
    if is_sort_by_relevance
      { current_option: I18n.t(:by_relevance),
        extra_params: { sort_by: 'date' },
        other_option: I18n.t(:by_date) }
    else
      { current_option: I18n.t(:by_date),
        extra_params: { sort_by: 'r' },
        other_option: I18n.t(:by_relevance) }
    end
  end

  def dropdown_filter_wrapper(html, dropdown_id, dropdown_label)
    dropdown_wrapper 'searches/dropdown_filter_wrapper', html, dropdown_id, dropdown_label
  end

  def clear_button_html(search, search_params)
    return unless search.custom_filter_params?

    time_params = { since_date: nil,
                    sort_by: nil,
                    tbs: nil,
                    until_date: nil }

    path = path_for_filterable_search search,
                                      search_params,
                                      time_params
    content_tag(:li) { link_to(I18n.t(:clear), path) }
  end

  def results_count_html(search)
    (return unless search.results.present)

    content_tag :li, id: 'results-count' do
      count = search.total
      result_count_str = I18n.t(:'searches.results_count',
                                count: count,
                                formatted_count: number_with_delimiter(count))
      content_tag :span, result_count_str
    end
  end

  def refine_search_html
    content_tag(:li, id: 'refine-search') do
      content_tag(:span, "#{I18n.t :refine_your_search}:")
    end
  end
end
