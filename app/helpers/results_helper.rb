module ResultsHelper
  def search_data(search, search_vertical)
    { data: {
        a: search.affiliate.name,
        l: search.affiliate.locale,
        q: search.query,
        s: search.module_tag,
        t: search.queried_at_seconds,
        v: search_vertical }
    }
  end

  def link_to_result_title(id, title, url, position, module_name, options = {})
    click_data = { i: id, p: position, s: module_name }
    link_to_if url.present?, title.html_safe, url, { data: { click: click_data } }.reverse_merge(options)
  end

  def link_to_web_result_title(result, position)
    title = translate_bing_highlights(h(result['title'])).html_safe

    click_data = { p: position }
    link_to title, result['unescapedUrl'], data: { click: click_data }
  end

  def link_to_indexed_document_title(result, position)
    title = translate_bing_highlights(h(result.title)).html_safe

    click_data = { p: position, s: 'AIDOC', i: result.id }
    link_to title, result.url, data: { click: click_data }
  end

  def link_to_news_item_title(instance, position)
    title = translate_bing_highlights(h(instance.title)).html_safe
    module_tag = instance.is_video? ? 'VIDS' : 'NEWS'

    click_data = { p: position, s: module_tag, i: instance.id }
    link_to title, instance.link, data: { click: click_data }
  end

  def link_to_news_item_thumbnail(instance, position)
    title = instance.title
    module_tag = 'VIDS'
    thumbnail_html = image_tag youtube_thumbnail_url(instance), alt: title
    duration_html = content_tag :span do
      content_tag(:span, nil, class: 'icon icon-play') << instance.duration
    end
    thumbnail_html << duration_html

    click_data = { p: position, s: module_tag, i: instance.id }
    link_to thumbnail_html, instance.link, data: { click: click_data }
  end

  def link_to_tweet_link(tweet, title, url, position, options = {})
    clicked_url = options.delete(:url) { url }
    click_data = { i: tweet.id, p: position, s: 'TWEET', u: clicked_url }
    link_to title, url, { data: { click: click_data } }.reverse_merge(options)
  end

  def link_to_related_search(search, related_term, position)
    click_data = { p: position, s: 'SREL' }
    link_to related_term.downcase.html_safe,
            search_path(affiliate: search.affiliate.name, query: strip_tags(related_term)),
            data: { click: click_data }
  end
end
