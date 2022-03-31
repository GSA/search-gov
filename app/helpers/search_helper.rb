# frozen_string_literal: true

module SearchHelper
  SPECIAL_URL_PATH_EXT_NAMES = %w{doc pdf ppt ps rtf swf txt xls docx pptx xlsx}
  EMPTY_STRING = ''

  def link_to_offer_commercial_image_results(search_url)
    link = link_to t('searches.commercial_results.search_again'), search_url, class: "search-again-link"

    content_tag :div, :class => "" do
      concat content_tag(:h6, t('searches.commercial_results.find_what_looking_for')) if
        t('searches.commercial_results.find_what_looking_for', :default => EMPTY_STRING) != EMPTY_STRING
      concat simple_format(t('searches.commercial_results.see_more_image_results', link: link).html_safe)
    end
  end

  def link_to_offer_commercial_web_results(search_url)
    link = link_to t('searches.commercial_results.search_again'), search_url, class: "search-again-link"

    content_tag :div, :class => "" do
      concat content_tag(:h6, t('searches.commercial_results.find_what_looking_for')) if
        t('searches.commercial_results.find_what_looking_for', :default => EMPTY_STRING) != EMPTY_STRING
      concat simple_format(t('searches.commercial_results.see_more_web_results', link: link).html_safe)
    end
  end

  def link_to_other_web_results(template, query)
    cleaned_query = URI.encode_www_form_component(query)
    template.sub('{QUERY}', cleaned_query).html_safe
  end

  def display_web_result_extname_prefix(web_result)
    display_result_extname_prefix(web_result['unescapedUrl'])
  end

  def display_result_extname_prefix(url)
    begin
      path_extname = File.extname(URI.parse(url).path)[1..]
      if SPECIAL_URL_PATH_EXT_NAMES.include?( path_extname.downcase )
        extname_span(path_extname)
      else
        ''
      end
    rescue
      ''
    end
  end

  def extname_span(extname)
    raw "<span class=\"uext_type\">[#{extname.upcase}]</span> "
  end

  def display_result_description(result)
    truncate_html(translate_bing_highlights(h(result['content'])))
  end

  def news_description(instance)
    truncate_html(translate_bing_highlights(h(instance.description))).sub(/^([^A-Z<])/,'...\1').html_safe
  end

  def translate_bing_highlights(body)
    body.gsub(/\uE000/, '<strong>').gsub(/\uE001/, '</strong>')
  end

  def strip_bing_highlights(body)
    body.gsub(/\uE000/, '').gsub(/\uE001/, '')
  end

  def image_search?
    controller.controller_name == 'image_searches'
  end

  def render_feed_name_in_govbox(affiliate, rss_feed_url_id)
    feed_name = RssFeedUrl.find_parent_rss_feed_name(affiliate, rss_feed_url_id)
    content_tag(:span, feed_name, class: 'feed-name') if feed_name
  end

  private

  def youtube_thumbnail_url(news_item)
    news_item.youtube_thumbnail_url
  end

  def hidden_field_tag_if_key_exists(param_sym, value = params[param_sym])
    hidden_field_tag param_sym, value if value
  end

  def search_bar_class(search)
    'has-query-term' if search.query.present?
  end
end
