module ResultsHelper
  def search_data(search, search_vertical)
    { data: {
      affiliate: search.affiliate.name,
      vertical: search_vertical,
      query: search.query
    } }
  end

  def link_to_result_title(title, url, position, module_code, options = {})
    # Used for i14y results
    click_data = { position: position, module_code: module_code }
    link_to_if url.present?, title.html_safe, url, { data: { click: click_data } }.reverse_merge(options)
  end

  def link_to_web_result_title(result, position, module_code)
    # Used for Bing results
    title = translate_bing_highlights(h(result['title'])).html_safe

    click_data = { position: position, module_code: module_code }
    link_to title, result['unescapedUrl'], data: { click: click_data }
  end

  def link_to_sitelink(title, url, position)
    # Used on SEC sites? How to set this up for tests? Is this used anymore. I don't see them on the live SEC site.

    click_data = { position: position, module_code: 'DECOR' }
    link_to title, url, data: { click: click_data }
  end

  def link_to_federal_register_document_title(document, position)
    # Not sure how to set up for system tests, but it looks like it should work.

    click_data = { position: position, module_code: 'FRDOC' }
    link_to document.title.html_safe, document.html_url, { data: { click: click_data }}
  end

  def link_to_image_result_title(result, position, options = { tabindex: -1 })
    # No integration tests
    title = translate_bing_highlights(h(result['title'])).html_safe

    # TODO - find the right Module codes
    click_data = { position: position, module_code: 'IMAG' }
    link_to title, result['Url'], { data: { click: click_data } }.merge(options)
  end

  def link_to_image_thumbnail(result, position)
    # No integration tests
    title = translate_bing_highlights(h(result['title'])).html_safe
    click_data = { position: position, module_code: 'IMAG' }

    link_to result['Url'], data: { click: click_data } do
      image_tag(result['Thumbnail']['Url'], alt: title)
    end
  end

  def link_to_indexed_document_title(result, position)
    # No integration tests
    title = translate_bing_highlights(h(result.title)).html_safe

    click_data = { position: position, module_code: 'AIDOC' }
    link_to title, result.url, data: { click: click_data }
  end

  def link_to_news_item_title(instance, position, module_code = 'NEWS', options = {})
    # No integration tests
    title = translate_bing_highlights(h(instance.title)).html_safe

    click_data = { position: position, module_code: module_code }
    link_to title, instance.link, { data: { click: click_data } }.reverse_merge(options)
  end

  def link_to_news_item_thumbnail(module_code, instance, position)
    # No integration tests
    thumbnail_html =
      case module_code
        when 'NIMAG' then image_news_item_thumbnail_html instance
        when 'VIDS' then video_news_item_thumbnail_html instance
      end

    click_data = { position: position, module_code: module_code }
    link_to thumbnail_html, instance.link, data: { click: click_data }
  end

  def image_news_item_thumbnail_html(news_item)
    image_tag news_item.thumbnail_url, alt: news_item.title
  end

  def video_news_item_thumbnail_html(news_item)
    thumbnail_html = image_tag youtube_thumbnail_url(news_item), alt: news_item.title
    duration_html = content_tag :span do
      content_tag(:span, nil, class: 'icon icon-play') << news_item.duration
    end
    thumbnail_html << duration_html
  end

  def link_to_tweet_link(tweet, title, url, position, options = {})
    # No integration tests

    clicked_url = options.delete(:url) { url }
    click_data = { position: position, module_code: 'TWEET' }
    link_to title, url, { data: { click: click_data } }.reverse_merge(options)
  end

  def link_to_related_search(search, related_term, position)
    # No integration tests

    click_data = { position: position, module_code: 'SREL' }
    link_to related_term.downcase.html_safe,
            search_path(affiliate: search.affiliate.name, query: strip_tags(related_term)),
            data: { click: click_data }
  end
end
