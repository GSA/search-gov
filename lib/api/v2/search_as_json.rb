module Api::V2::SearchAsJson
  def as_json(_options = {})
    hash = {}
    as_json_append_web hash
    as_json_append_govbox_set hash
    hash
  end

  protected

  def as_json_append_web(hash)
    web_hash = {}
    web_hash[:total] = @total if @total
    web_hash[:next_offset] = @next_offset
    yield web_hash if block_given?
    web_hash[:results] = as_json_results_to_hash
    hash[:web] = web_hash
  end

  def as_json_append_govbox_set(hash)
    hash[:text_best_bets] = boosted_contents ? boosted_contents.results : []
    hash[:graphic_best_bets] = featured_collections ? featured_collections.results : []
    hash[:health_topics] = med_topic ? as_json_health_topics : []
    hash[:job_openings] = jobs ? as_json_job_openings : []
    hash[:recent_tweets] = tweets ? tweets.results : []
    yield if block_given?
    hash[:federal_register_documents] = federal_register_documents ? as_json_federal_register_documents : []
    hash[:related_search_terms] = related_search ? related_search : []
  end

  def as_json_results_to_hash
    @results.collect { |result| as_json_result_hash result }
  end

  def as_json_result_hash(result)
    result.description ||= result.content
    result.url ||= result.unescaped_url
    { title: result.title,
      url: result.url,
      snippet: as_json_build_snippet(result.description) }
  end

  def as_json_build_snippet(description)
    if description =~ /\uE000/
      description.sub!(/^([^A-Z<])/, '...\1')
    else
      description = description.truncate(150, separator: ' ')
    end
    description
  end

  def as_json_video_news(news_items)
    return [] unless news_items

    news_items.collect { |news_item| as_json_video_news_item news_item }
  end

  def as_json_video_news_item(news_item)
    news_item_hash = as_json_news_item news_item, 'YouTube'
    news_item_hash.merge!(duration: news_item.duration) if news_item.duration
    news_item_hash.merge(thumbnail_url: news_item.youtube_thumbnail_url)
  end

  def as_json_news_item(news_item, source = nil)
    source ||= RssFeedUrl.find_parent_rss_feed_name(@affiliate, news_item.rss_feed_url_id)
    { title: news_item.title,
      url: news_item.link,
      snippet: news_item.description,
      publication_date: news_item.published_at.to_date.to_s(:db),
      source: source }
  end

  def as_json_federal_register_documents
    federal_register_documents.results.collect do |document|
      comments_close_on = document.comments_close_on ? document.comments_close_on.to_s(:db) : nil
      { id: document.id,
        document_number: document.document_number,
        document_type: document.document_type,
        title: document.title,
        url: document.html_url,
        agency_names: document.contributing_agency_names,
        page_length: document.page_length,
        start_page: document.start_page,
        end_page: document.end_page,
        publication_date: document.publication_date.to_s(:db),
        comments_close_date: comments_close_on }
    end
  end

  def as_json_job_openings
    jobs.collect do |job|
      job_hash = job.to_hash.except('id')
      org_codes = @affiliate.agency ? @affiliate.agency.joined_organization_codes : ""
      job_hash.merge(org_codes: org_codes)
    end
  end

  def as_json_health_topics
    related_topics = med_topic.med_related_topics.collect do |related_topic|
      { title: related_topic.title,
        url: related_topic.url }
    end

    related_sites = med_topic.med_sites.collect do |med_site|
      { title: med_site.title,
        url: med_site.url }
    end

    [{ title: med_topic.medline_title,
       url: med_topic.medline_url,
       snippet: med_topic.truncated_summary,
       related_topics: related_topics,
       related_sites: related_sites }]
  end
end
