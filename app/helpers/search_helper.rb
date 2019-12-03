# coding: utf-8
module SearchHelper

  SPECIAL_URL_PATH_EXT_NAMES = %w{doc pdf ppt ps rtf swf txt xls docx pptx xlsx}
  EMPTY_STRING = ""

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
    template.sub('{QUERY}', query).html_safe
  end

  def result_partial_for(search)
    if search.is_a?(LegacyImageSearch)
      "/image_searches/result"
    else
      "/searches/result"
    end
  end

  def display_image_result_link(result, search, affiliate, index, vertical, max_width = nil, max_height = nil)
    affiliate_name = affiliate.name rescue ""
    query = search.spelling_suggestion ? search.spelling_suggestion : search.query
    onmousedown_attribute = onmousedown_attribute_for_image_click(query, result["Url"], index, affiliate_name, search.module_tag, search.queried_at_seconds, vertical)
    html = tracked_click_thumbnail_image_link(result, onmousedown_attribute, max_width, max_height)
    raw html << tracked_click_thumbnail_link(result, onmousedown_attribute)
  end

  def tracked_click_thumbnail_image_link(result, onmousedown_attr, max_width = nil, max_height = nil)
    raw link_to thumbnail_image_tag(result, max_width, max_height),
            result["Url"],
            :onmousedown => onmousedown_attr,
            :alt => result["title"],
            :rel => "no-follow",
            :class => 'image-link'
  end

  def tracked_click_thumbnail_link(result, onmousedown_attr)
    link = URI.parse(result["Url"]).host rescue truncate_url(result["Url"])
    link_to link, result["Url"], :onmousedown => onmousedown_attr, :rel => "no-follow", class: 'host-link'
  end

  def thumbnail_image_tag(result, max_width=nil, max_height=nil)
    width = result["Thumbnail"]["Width"].to_f
    height = result["Thumbnail"]["Height"].to_f
    reductions = [
      (max_width && width > max_width) ? (max_width.to_f / width) : 1,
      (max_height && height > max_height) ? (max_height.to_f / height) : 1
    ]
    reduction = reductions.min
    opts = { title: result["title"] }
    opts.merge!(width: (width * reduction).to_i, height: (height * reduction).to_i) unless width.zero? or height.zero?
    raw image_tag result["Thumbnail"]["Url"], opts
  end

  def display_web_result_extname_prefix(web_result)
    display_result_extname_prefix(web_result['unescapedUrl'])
  end

  def display_result_extname_prefix(url)
    begin
      path_extname = File.extname(URI.parse(url).path)[1..-1]
      if SPECIAL_URL_PATH_EXT_NAMES.include?( path_extname.downcase )
        extname_span(path_extname)
      else
        ""
      end
    rescue
      ""
    end
  end

  def extname_span(extname)
    raw "<span class=\"uext_type\">[#{extname.upcase}]</span> "
  end

  def display_web_result_title(result, search, affiliate, position, vertical)
    raw tracked_click_link(h(result['unescapedUrl']), translate_bing_highlights(h(result['title'])), search, affiliate, position, search.module_tag, vertical)
  end

  def highlight_string(s)
    "<strong>#{s}</strong>".html_safe
  end

  def link_with_click_tracking(html_safe_title, url, affiliate, query, position, source, vertical, model_id = nil)
    aff_name = affiliate.name rescue ""
    onmousedown = onmousedown_for_click(query, position, aff_name, source, Time.now.to_i, vertical, model_id)
    raw "<a href=\"#{h url}\" #{onmousedown}>#{html_safe_title}</a>"
  end

  def job_link_with_click_tracking(html_safe_title, url, affiliate, query, position, vertical)
    link_with_click_tracking(html_safe_title, url, affiliate, query, position, "JOBS", vertical)
  end

  def tracked_click_link(url, title, search, affiliate, position, source, vertical = :web, opts = nil)
    aff_name = affiliate.nil? ? "" : affiliate.name
    query = search.spelling_suggestion || search.query
    query = query.gsub("'", "\\\\'")
    onmousedown = onmousedown_for_click(query, position, aff_name, source, search.queried_at_seconds, vertical)
    raw "<a href=\"#{url}\" #{onmousedown} #{opts}>#{title}</a>"
  end

  def tweet_link_with_click_tracking(html_safe_text, url, twitter_url, affiliate, search, position, vertical)
    affiliate_name = affiliate.name rescue ""
    onmousedown = %Q[onmousedown="#{onmousedown_for_tweet_click_attribute(search.query, url, position, affiliate_name, 'TWEET', search.queried_at_seconds, vertical)}"]
    raw "<a href=\"#{URI.escape(twitter_url)}\" #{onmousedown}>#{html_safe_text}</a>"
  end

  def onmousedown_for_tweet_click_attribute(query, url, zero_based_index, affiliate_name, source, queried_at, vertical)
    tracked_url = url ? "'#{URI.escape(url)}'" : 'this.href'
    "return clk('#{h query}', #{tracked_url}, #{zero_based_index + 1}, '#{affiliate_name}', '#{source}', #{queried_at}, '#{vertical}', '#{I18n.locale.to_s}')"
  end

  def onmousedown_for_click(query, zero_based_index, affiliate_name, source, queried_at, vertical, model_id = nil)
    %Q[onmousedown="#{onmousedown_for_click_attribute(query, zero_based_index, affiliate_name, source, queried_at, vertical, model_id)}"]
  end

  def onmousedown_for_click_attribute(query, zero_based_index, affiliate_name, source, queried_at, vertical, model_id)
    "return clk('#{h query}',this.href, #{zero_based_index + 1}, '#{affiliate_name}', '#{source}', #{queried_at}, '#{vertical}', '#{I18n.locale.to_s}', '#{model_id}')"
  end

  def onmousedown_attribute_for_image_click(query, media_url, zero_based_index, affiliate_name, source, queried_at, vertical)
    "return clk('#{h(escape_javascript(query))}', '#{media_url}', #{zero_based_index + 1}, '#{affiliate_name}', '#{source}', #{queried_at}, '#{vertical}', '#{I18n.locale.to_s}')"
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

  def results_summary(search)
    return if search.fake_total?
    p_sum = make_summary_p(search)
    content_tag(:div, raw(p_sum), :id => "summary") << raw('&nbsp;&nbsp;&bull;&nbsp;&nbsp;')
  end

  def make_summary_p(search)
    approximate = search.total >= 100 ? t(:approximate) : ''
    total = pluralize(number_with_delimiter(search.total, :delimiter => ','), t(:result))
    if search.first_page?
      content_tag(:p, "#{approximate}#{total}")
    else
      content_tag(:p, t(:results_summary, :approximate => approximate.downcase, :page => search.page,
                        :total => total))
    end
  end

  def advanced_search_link(search_options, affiliate = nil)
    search_options ||= {}
    search_options.merge!(:action => 'advanced', :controller => 'searches', :format => nil)
    search_options.merge!(:affiliate => affiliate.name) if affiliate
    link_to((t :advanced_search), advanced_search_path(search_options), :id => 'advanced_search_link')
  end

  def image_search?
    controller.controller_name == 'image_searches'
  end

  def no_results_for(query)
    content_tag(:p, (t :no_results_for_and_try, :query => query), :class => "noresults")
  end

  def no_news_results_for(search)
    reset_filters_link = link_to(t(:remove_all_filters), search_path(:affiliate => search.affiliate.name, :query => search.query))
    time_filter = FilterableSearch::TIME_BASED_SEARCH_OPTIONS[params[:tbs]]
    time_filter_message = time_filter.blank? ? '' : " #{t("the_last_#{time_filter.to_s}".to_sym)}"
    no_results_message = "#{t(:no_results_for_query, :query => h(search.query))}#{time_filter_message}. "
    no_results_message << reset_filters_link.html_safe
    no_results_message << " #{t(:or_try_broader)}"
    content_tag(:p, no_results_message.html_safe, :class => "noresults")
  end

  def related_topics_header(affiliate, query)
    related_topics_suffix = content_tag :span, "#{I18n.t :by} #{affiliate.display_name}", :class => 'recommended-by'
    "#{I18n.t :related_topics_prefix} '#{h query}' #{related_topics_suffix}".html_safe
  end

  def display_search_all_affiliate_sites_suggestion(search)
    return if search.matching_site_limits.nil? or search.matching_site_limits.empty?
    html = "We're including results for '#{h search.query}' from only #{h search.matching_site_limits.join(' ')}. "
    html << "Do you want to see results for "
    html << link_to("'#{h search.query}' from all sites", search_path(params.except(:sitelimit).permit))
    html << "?"
    raw content_tag(:h4, html.html_safe, :class => 'search-all-sites-suggestion')
  end

  def render_govbox(column = :center)
    if column == :center
      content = content_tag(:div, '', :class => 'govbox-wrapper-top')
      content << content_tag(:div, :class => 'govbox-wrapper-middle') do
        yield
      end
      content << content_tag(:div, '', :class => 'govbox-wrapper-bottom')
      raw(content_tag(:div, raw(content), :class => 'govbox'))
    elsif column == :right
      content = content_tag(:div, :class => 'right-column-govbox') do
        yield
      end
      raw(content)
    end
  end

  def search_results_by_logo(module_tag)
    if %w(AWEB AIMAG BWEB IMAG).include? module_tag
      alt = I18n.t(:results_by_bing)
      image_source = "searches/binglogo_#{I18n.locale.to_s}.gif"
      bing_class = %w(AWEB AIMAG).include?(module_tag) ? 'azure' : 'bing'
      image_tag(image_source, :alt => alt, :class => "results-by-logo #{bing_class}")
    elsif %w(GWEB GIMAG).include? module_tag
      alt = I18n.t(:results_by_google)
      image_source = "searches/googlelogo_#{I18n.locale.to_s}.gif"
      image_tag(image_source, :alt => alt, :class => 'results-by-logo google')
    else
      alt = I18n.t(:results_by_usasearch)
      image_source = "searches/results_by_usasearch_#{I18n.locale.to_s}.png"
      link_to(image_tag(image_source, :alt => alt),
                        Rails.application.secrets.organization['blog_url'],
                        :class => 'results-by-logo usasearch')
    end
  end

  def render_facet_navs(affiliate, search, search_params)
    search_path_method = (search.class.to_s.underscore + '_path').to_sym
    html = []
    search.aggregations.each do |agg|
      next unless agg.rows.any?
      facet_navs = []

      custom_facet_label = affiliate.dublin_core_mappings[:"dc_#{agg.name}"]
      facet_label = custom_facet_label.present? ? custom_facet_label : t("facet.all_#{agg.name}s")
      any_nav = link_to_unless search_params[agg.name.to_sym].blank?, facet_label, send(search_path_method, search_params.remove(agg.name.to_sym)) do |name|
        content_tag(:div, name, :class => 'selected')
      end
      facet_navs << content_tag(:li, any_nav.html_safe)

      shown_items = 1

      selected_row = agg.rows.select { |row| params[agg.name.to_sym] == row.value }.first
      if selected_row
        selected_nav = content_tag(:div, selected_row.value, :class => 'selected')
        facet_navs << content_tag(:li, selected_nav.html_safe)
        shown_items += 1
      end

      not_selected_rows = agg.rows.reject { |row| params[agg.name.to_sym] == row.value }
      total_rows = shown_items + not_selected_rows.count
      not_selected_rows.each do |row|
        facet_nav = link_to(row.value, send(search_path_method, search_params.merge(agg.name.to_sym => row.value)))
        if (total_rows <= 6) or (shown_items <= 4)
          facet_class = nil
        else
          facet_class = 'collapsible'
        end
        facet_navs << content_tag(:li, facet_nav.html_safe, :class => facet_class)
        shown_items += 1
      end

      if shown_items > 6
        more_facets_wrapper = content_tag(:div, :class => 'more-facets-wrapper') do
          content = []
          content << content_tag(:span, t(:show_more), :class => 'more-facets')
          content << content_tag(:span, t(:show_less), :class => 'less-facets')
          content << content_tag(:span, nil, :class => 'triangle show-options')
          content.join("\n").html_safe
        end
        facet_navs << content_tag(:li, more_facets_wrapper.html_safe)
      end
      (html << content_tag(:ul, facet_navs.join("\n").html_safe, :id => "facet_#{agg.name}", :class => 'facet')) unless facet_navs.empty?
    end
    html.join("\n").html_safe unless html.empty?
  end

  def render_feed_name_in_govbox(affiliate, rss_feed_url_id)
    feed_name = RssFeedUrl.find_parent_rss_feed_name(affiliate, rss_feed_url_id)
    content_tag(:span, feed_name, class: 'feed-name') if feed_name
  end

  private

  def render_news_item_video_thumbnail_link_with_click_tracking(affiliate, search, search_vertical, news_item, index)
    link_with_click_tracking(image_tag(youtube_thumbnail_url(news_item), :alt => strip_bing_highlights(news_item.title)).html_safe,
                             news_item.link, affiliate, search.query, index, 'VIDS', search_vertical, news_item.id)
  end

  def render_news_item_image_thumbnail_link_with_click_tracking(affiliate, search, search_vertical, news_item, index)
    content = image_tag news_item.thumbnail_url, alt: news_item.title
    host = URI.parse(news_item.link).host rescue nil
    content << content_tag(:span, host, class: 'host')
    link_with_click_tracking(content.html_safe, news_item.link, affiliate, search.query, index, 'NIMAG', search_vertical)
  end

  def youtube_thumbnail_url(news_item)
    news_item.youtube_thumbnail_url
  end

  def left_nav_label(label_text)
    label_text.blank? ? '&nbsp;'.html_safe : content_tag(:h3, label_text, :id => 'left_nav_label')
  end

  def hidden_field_tag_if_key_exists(param_sym, value = params[param_sym])
    hidden_field_tag param_sym, value if value
  end

  def search_bar_class(search)
    'has-query-term' if search.query.present?
  end
end
