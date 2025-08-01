module SpellingSuggestionsHelper
  def spelling_suggestion_links(search, search_options, &block)
    if search.spelling_suggestion
      suggested_query = strip_bing_highlights(search.spelling_suggestion)
      opts = { affiliate: search.affiliate.name, query: suggested_query }
      opts.merge!(sitelimit: search_options[:site_limits]) if search_options[:site_limits]
      suggested_url = search_path(opts)

      opts.merge!(query: overridden_query(search.query))
      original_url = search_path(opts)
      yield suggested_query, suggested_url, original_url
    end
  end

  def search_suggestion_links(search, &block)
    suggested_query = strip_bing_highlights(search.spelling_suggestion)
    opts = { affiliate: search.affiliate.name, query: suggested_query }
    suggested_url = search_path(opts)
    yield suggested_query, suggested_url
  end

  def overridden_query(query)
    "+#{query}"
  end

  def spelling_suggestion(search, search_options)
    spelling_suggestion_links(search, search_options) do |suggested_query, suggested_url, original_url|
      render_suggestion(original_url, search, suggested_query, suggested_url, 'BSPEL', 'OVER')
    end
  end

  def search_suggestion(search, module_tag)
    search_suggestion_links(search) do |suggested_query, suggested_url|
      render_spelling(suggested_query, suggested_url, module_tag)
    end if search.spelling_suggestion
  end

  def render_spelling(suggested_query, suggested_url, module_tag)
    suggested_query_link = link_to_result_title(h(suggested_query),
                                                suggested_url, 1, module_tag)
    showing_results_for = t :showing_results_for, corrected_query: suggested_query_link
    render partial: 'searches/spelling_correction',
           locals: { showing_results_for: showing_results_for.html_safe}
  end

  def render_suggestion(original_url, search, suggested_query, suggested_url, spelling_module_name, overclick_module_name)
    suggested_query_link = link_to_result_title(h(suggested_query), suggested_url,
                                                1, spelling_module_name)
    original_query_link = link_to_result_title(h(search.query), original_url,
                                               1, overclick_module_name)
    showing_results_for = t :showing_results_for, corrected_query: suggested_query_link
    search_instead_for = t :search_instead_for, original_query: original_query_link

    render partial: 'searches/spelling_suggestion',
           locals: { showing_results_for: showing_results_for.html_safe,
                     search_instead_for: search_instead_for.html_safe }
  end
end
