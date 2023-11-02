# frozen_string_literal: true

module ReactHelper
  # rubocop:disable Metrics/AbcSize
  def search_results_layout(search, params, vertical, affiliate)
    data = {
      additionalResults: search.govbox_set,
      alert: search_page_alert(affiliate.alert),
      currentLocale: affiliate.locale,
      extendedHeader: affiliate.use_extended_header,
      fontsAndColors: affiliate.visual_design_json,
      footerLinks: links(affiliate, :footer_links),
      navigationLinks: navigation_links(search, params),
      newsLabel: news_label(search),
      noResultsMessage: no_result_message(search),
      params: params,
      relatedSearches: related_searches(search),
      relatedSites: related_sites(search),
      relatedSitesDropdownLabel: affiliate.related_sites_dropdown_label,
      resultsData: search.normalized_results,
      translations: translations(affiliate.locale),
      vertical: vertical
    }

    react_component('SearchResultsLayout', data.compact_blank)
  end

  # rubocop:disable Metrics/AbcSize
  def image_search_results_layout(search, params, vertical, affiliate)
    data = {
      currentLocale: affiliate.locale,
      extendedHeader: affiliate.use_extended_header,
      fontsAndColors: affiliate.visual_design_json,
      footerLinks: links(affiliate, :footer_links),
      navigationLinks: navigation_links(search, params),
      noResultsMessage: no_result_message(search),
      params: params,
      resultsData: search.format_results,
      translations: translations(affiliate.locale),
      vertical: vertical
    }

    react_component('SearchResultsLayout', data.compact_blank)
  end
  # rubocop:enable Metrics/AbcSize

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

  def no_result_message(search)
    return unless search.results.blank? && search.query.present?

    search.affiliate.no_results_error
  end

  def translations(locale)
    I18n.backend.translations.slice(:en, locale.to_sym)
  end

  def search_page_alert(alert)
    return if !alert || (alert.text.blank? && alert.title.blank?)

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
        label: navigable.name,
        url: navigable_path(navigable, search, search_params)
      }
    end
  end
end
