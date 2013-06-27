module MedTopicsHelper
  def display_medline_result_title(search, affiliate)
    raw tracked_click_link(h(search.med_topic.medline_url), highlight_string(h(search.med_topic.medline_title)), search, affiliate, 0, "MEDL")
  end

  def display_medline_results_description(summary, query)
    highlight(truncate_html(summary, length: 300), query).html_safe
  end

  def display_medline_url_with_click_tracking(title, url, search, affiliate)
    onmousedown = onmousedown_for_click_attribute(search.query, 0, affiliate.name, 'MEDL', search.queried_at_seconds, :web)
    link_to(title, url, :onmousedown => onmousedown)
  end
end
