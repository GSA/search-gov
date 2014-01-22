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

  def link_to_best_bet_title(id, title, url, position, module_name)
    click_data = { i: id, p: position, s: module_name }
    link_to_if url.present?, title.html_safe, url, data: { click: click_data }
  end

  def link_to_web_result_title(search, result, position)
    title = translate_bing_highlights(h(result['title'])).html_safe

    click_data = { p: position }
    link_to title, result['unescapedUrl'], data: { click: click_data }
  end

  def link_to_news_item_title(hit, hit_url, position)
    title = highlight_hit(hit, :title).html_safe
    module_tag = hit.instance.is_video? ? 'VIDS' : 'NEWS'

    click_data = { p: position, s: module_tag }
    link_to title, hit_url, data: { click: click_data }
  end

  def link_to_tweet_link(tweet, title, url, position, options = {})
    clicked_url = options.delete(:url) { url }
    click_data = { i: tweet.instance.id, p: position, s: 'TWEET', u: clicked_url }
    link_to title, url, { data: { click: click_data } }.reverse_merge(options)
  end

  def link_to_related_search(search, related_term, position)
    click_data = { p: position, s: 'SREL' }
    link_to related_term.downcase.html_safe,
            search_path(affiliate: search.affiliate.name, query: strip_tags(related_term)),
            data: { click: click_data }
  end
end
