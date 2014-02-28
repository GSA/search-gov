module MedTopicsHelper
  MAX_MED_TOPIC_DESCRIPTION_LENGTH = 200.freeze

  def med_topic_description(med_topic)
    sentences = Sanitize.clean(med_topic.summary_html).squish.split(/\.\s*/)
    description = ''

    sentences.slice(0,3).each do |sentence|
      break if (description.length + sentence.length + 1) > MAX_MED_TOPIC_DESCRIPTION_LENGTH
      description << sentence << '. '
    end
    description
  end

  def legacy_display_medline_result_title(search, affiliate)
    raw tracked_click_link(h(search.med_topic.medline_url), highlight_string(h(search.med_topic.medline_title)), search, affiliate, 0, "MEDL")
  end

  def legacy_display_medline_results_description(summary, query)
    highlight(truncate_html(summary, 300), query).html_safe
  end

  def legacy_display_medline_url_with_click_tracking(title, url, search, affiliate)
    onmousedown = onmousedown_for_click_attribute(search.query, 0, affiliate.name, 'MEDL', search.queried_at_seconds, :web, nil)
    link_to(title, url, :onmousedown => onmousedown)
  end
end
