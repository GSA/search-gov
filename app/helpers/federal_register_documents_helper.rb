module FederalRegisterDocumentsHelper
  def federal_register_document_info(document)
    document_type_span = content_tag :span, document.document_type

    fr_agency_names = federal_register_document_contributing_agency_names document.federal_register_agencies
    fr_agencies_html = federal_register_agencies_html fr_agency_names

    publication_date_span = content_tag :span, document.publication_date.to_s(:long)
    "A #{document_type_span} #{fr_agencies_html} posted on #{publication_date_span}.".html_safe
  end

  def federal_register_document_contributing_agency_names(fr_agencies)
    parent_ids = fr_agencies.collect(&:parent_id).compact.uniq
    fr_agencies.reject { |fr_agency| parent_ids.include? fr_agency.id }.collect(&:name)
  end

  def federal_register_agencies_html(fr_agency_names)
    agency_spans = fr_agency_names.sort.collect { |name| content_tag :span, name }
    last_agency_span = agency_spans.slice!(-1)
    agencies_html = 'by the ' << agency_spans.join(', the ').html_safe
    agencies_html << ' and the ' if agency_spans.present?
    agencies_html << last_agency_span
  end

  def federal_register_document_comment_period(document)
    return unless document.comments_close_on
    today = Date.current

    if document.comments_close_on < today
      'Comment period ended.'
    elsif document.comments_close_on == today
      'Comment period ends today.'
    else
      date_delta = (document.comments_close_on - today).to_i
      date_delta_span = content_tag :span, pluralize(date_delta, 'day')
      comments_close_on_span = content_tag :span, document.comments_close_on.to_s(:long)
      "Comment period ends in #{date_delta_span} (#{comments_close_on_span}).".html_safe
    end
  end

  def federal_register_document_page_info(document)
    content = "Pages #{document.start_page} - #{document.end_page} "
    content << "(#{pluralize(document.page_length, 'page')}) "
    content << "[FR DOC #: #{document.document_number}]"
  end

  def link_to_federal_register_advanced_search(search)
    federal_register_agency_id = search.affiliate.agency.federal_register_agency.id
    url_params = { conditions: { agency_ids: [federal_register_agency_id], term: search.query } }
    url = "https://www.federalregister.gov/articles/search?#{url_params.to_param}"
    link_to 'See more at FederalRegister.gov', url
  end
end
