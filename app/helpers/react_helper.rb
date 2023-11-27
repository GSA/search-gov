# frozen_string_literal: true

module ReactHelper
  def search_results_layout(search, params, vertical, affiliate, search_options)
    data = {
      additionalResults: search.govbox_set,
      alert: search_page_alert(affiliate.alert),
      currentLocale: affiliate.locale,
      extendedHeader: affiliate.use_extended_header,
      fontsAndColors: affiliate.visual_design_json,
      footerLinks: links(affiliate, :footer_links),
      identifierContent: identifier_content(affiliate),
      identifierLinks: links(affiliate, :identifier_links),
      navigationLinks: navigation_links(search, params),
      newsLabel: news_label(search),
      noResultsMessage: no_result_message(search),
      agencyName: agency_name(affiliate.agency),
      jobsEnabled: affiliate.jobs_enabled?,
      page: page_data(affiliate),
      params: params,
      relatedSearches: related_searches(search),
      relatedSites: related_sites(search),
      relatedSitesDropdownLabel: affiliate.related_sites_dropdown_label,
      resultsData: search.normalized_results,
      sitelimit: sitelimit_alert(search, params),
      spellingSuggestion: spelling_text(search, search_options),
      translations: translations(affiliate.locale),
      vertical: vertical
    }

    react_component('SearchResultsLayout', data.compact_blank)
  end

  def page_data(affiliate)
    {
      title: affiliate.display_name,
      logo: {
        text: logo_text(affiliate.header_logo_blob),
        url: header_logo_url(affiliate.header_logo)
      }
    }
  end

  def header_logo_url(header_logo)
    return if header_logo.blank?

    url_for(header_logo)
  end

  def logo_text(blob)
    return unless blob&.custom_metadata

    blob.custom_metadata[:alt_text]
  end

  def image_search_results_layout(search, params, vertical, affiliate)
    data = {
      extendedHeader: affiliate.use_extended_header,
      fontsAndColors: affiliate.visual_design_json,
      footerLinks: links(affiliate, :footer_links),
      navigationLinks: navigation_links(search, params),
      page: page_data(affiliate),
      params: params,
      resultsData: search.format_results,
      translations: translations(affiliate.locale),
      vertical: vertical
    }

    react_component('SearchResultsLayout', data.compact_blank)
  end

  private

  def related_searches(search)
    return [] if search.is_a?(NewsSearch) || search.related_search.nil?

    search.related_search.map do |related_term|
      {
        label: related_term,
        link: search_path(affiliate: search.affiliate.name, query: strip_tags(related_term))
      }
    end
  end

  def news_label(search)
    return if search.query.blank? || search.is_a?(NewsSearch)

    affiliate = search.affiliate
    {
      newsAboutQuery: news_about_query(affiliate, search.query),
      results: news_items_results(affiliate, search)
    }
  end

  def sitelimit_alert(search, params)
    return unless params[:sitelimit]

    {
      sitelimit: params[:sitelimit],
      url: search_path(affiliate: search.affiliate.name, query: search.query)
    }
  end

  def spelling_text(search, search_options)
    return if search.spelling_suggestion.blank?

    spelling_suggestion_links(search, search_options) do |suggested_query, suggested_url, original_url|
      {
        suggested: link_to(suggested_query, suggested_url),
        original: link_to(search.query, original_url)
      }
    end
  end

  def no_result_message(search)
    return unless search.results.blank? && search.query.present?

    search.affiliate.no_results_error
  end

  def translations(locale)
    I18n.backend.translations.slice(:en, locale.to_sym)
  end

  def search_page_alert(alert)
    return unless alert&.renderable?

    alert.slice('text', 'title')
  end

  def related_sites(search)
    connections = search.affiliate.connections
    connections.map do |connection|
      {
        label: connection.label,
        link: search_url(affiliate: connection.connected_affiliate.name, query: search.query)
      }
    end
  end

  def links(affiliate, type)
    links = affiliate.send(type)

    links.map do |link|
      {
        title: link.title,
        url: link.url
      }
    end
  end

  def default_tab(search, params)
    {
      active: is_default_search?(search),
      facet: 'Default',
      label: search.affiliate.default_search_label,
      url: search_path(params.slice(:affiliate, :m).merge(query: search.query))
    }
  end

  def navigation_links(search, search_params)
    non_default_search_navigable = detect_non_default_search_navigable(search)

    [default_tab(search, search_params)] + renderable_navigations(search).map do |navigation|
      navigable = navigation.navigable

      {
        active: non_default_search_navigable == navigable,
        facet: navigation.navigable_facet_type,
        label: navigable.name,
        url: navigable_path(navigable, search, search_params)
      }
    end
  end

  def identifier_content(affiliate)
    {
      domainName: affiliate.identifier_domain_name,
      parentAgencyName: affiliate.parent_agency_name,
      parentAgencyLink: affiliate.parent_agency_link
    }
  end

  def agency_name(agency)
    return if agency.nil?

    agency.abbreviation || agency.name
  end
end
