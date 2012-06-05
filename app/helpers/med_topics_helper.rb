module MedTopicsHelper
  def display_medline_result_title(search, affiliate)
    raw tracked_click_link(h(search.med_topic.medline_url), highlight_string(h(search.med_topic.medline_title)), search, affiliate, 0, "MEDL")
  end

  def display_medline_results_description(summary, query)
    highlight(truncate_html_prose_on_words(summary, 300), query).html_safe
  end

  def display_medline_topic_with_click_tracking(med_topic, query, locale, affiliate)
    onmousedown = onmousedown_for_click(query, 0, nil, 'MEDL', Time.now.to_i, :web)
    affiliate_name = affiliate.nil? ? nil : affiliate.name
    raw "<a href=\"#{h search_path(:affiliate => affiliate_name, :query => med_topic.medline_title, :locale => locale)}\" #{onmousedown}>#{med_topic.medline_title}</a>"
  end

  def display_medline_clinical_trail_with_click_tracking(mesh_title, query)
    onmousedown = onmousedown_for_click(query, 0, nil, 'MEDL', Time.now.to_i, :web)
    raw "<a href=\"http://clinicaltrials.gov/search/open/condition=#{URI.escape("\"" + h(mesh_title) + "\"")}\" #{onmousedown}>#{mesh_title}</a>"
  end
end
