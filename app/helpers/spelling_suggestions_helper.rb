module SpellingSuggestionsHelper
  def spelling_suggestion_links(search, &block)
    if search.spelling_suggestion
      rendered_suggestion = translate_bing_highlights(search.spelling_suggestion)

      unless FuzzyMatcher.new(rendered_suggestion, search.query).matches?
        suggested_query = strip_bing_highlights(search.spelling_suggestion)
        opts = { affiliate: search.affiliate.name, query: suggested_query }
        suggested_url = image_search? ? image_search_path(opts) : search_path(opts)

        opts.merge!(query: "+#{search.query}")
        original_url = image_search? ? image_search_path(opts) : search_path(opts)
        yield suggested_query, suggested_url, original_url
      end
    end
  end

  def legacy_spelling_suggestion(search, affiliate, vertical)
    spelling_suggestion_links(search) do |suggested_query, suggested_url, original_url|
      did_you_mean = t :did_you_mean,
                       :assumed_term => tracked_click_link(suggested_url, h(suggested_query), search, affiliate, 0, 'BSPEL', vertical, "style='font-weight:bold'"),
                       :term_as_typed => tracked_click_link(original_url, h(search.query), search, affiliate, 0, 'OVER', vertical, "style='font-style:italic'")
      content_tag(:h4, raw(did_you_mean), :class => 'did-you-mean')
    end
  end

  def spelling_suggestion(search)
    spelling_suggestion_links(search) do |suggested_query, suggested_url, original_url|
      suggested_query_link = link_to_result_title nil, h(suggested_query), suggested_url, 1, 'BSPEL'
      original_query_link = link_to_result_title nil, h(search.query), original_url, 1, 'OVER'
      showing_results_for = t :showing_results_for, corrected_query: suggested_query_link
      search_instead_for = t :search_instead_for, original_query: original_query_link

      render partial: 'searches/spelling_suggestion',
             locals: { showing_results_for: showing_results_for.html_safe,
                       search_instead_for: search_instead_for.html_safe }
    end
  end
end
