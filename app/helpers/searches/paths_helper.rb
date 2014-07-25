module Searches::PathsHelper
  def path_for_image_search(search_params, query)
    image_search_params = search_params.slice(:affiliate).merge(query: query)
    image_search_path image_search_params
  end

  def path_for_document_collection_search(search_params, navigable, query)
    dc_params = navigable_params(search_params, :dc, navigable.id, query,
                                 :affiliate, :m, :sitelimit)
    docs_search_path dc_params
  end

  def path_for_rss_feed_search(search, search_params, navigable, extra_params = {})
    navigable_id = navigable.id if navigable
    rss_params = navigable_params(search_params, :channel, navigable_id, search.query,
                                  :affiliate, :m)

    rss_params.merge! extract_current_news_search_params(search)
    rss_params.merge! extra_params
    news_search_path rss_params
  end

  def navigable_params(search_params, id_sym, id, query, *keys)
    search_params.slice(*keys).merge(id_sym => id, :query => query)
  end

  def extract_current_news_search_params(search)
    return {} unless search.is_a? NewsSearch

    current_params = {}
    current_params[:sort_by] = 'r' if search.sort_by_relevance?

    if search.tbs
      current_params[:tbs] = search.tbs
    else
      current_params[:since_date] = render_date search.since
      current_params[:until_date] = render_date search.until
    end

    current_params
  end

end
