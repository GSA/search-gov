module Govboxable
  delegate :boosted_contents,
           :federal_register_documents,
           :med_topic,
           :news_items,
           :video_news_items,
           :featured_collections,
           :tweets,
           :jobs,
           :related_search,
           :to => :@govbox_set,
           :allow_nil => true

  def has_best_bets?
    has_boosted_contents? or has_featured_collections?
  end

  def has_boosted_contents?
    boosted_contents and boosted_contents.total > 0 and boosted_contents.results.size > 0
  end

  def best_bets_count
    boosted_contents_count + featured_collections_count
  end

  def boosted_contents_count
    has_boosted_contents? ? boosted_contents.results.size : 0
  end

  def featured_collections_count
    has_featured_collections? ? featured_collections.results.size : 0
  end

  def has_featured_collections?
    featured_collections and featured_collections.total > 0 and featured_collections.results.size > 0
  end

  def has_fresh_news_items?
    @has_fresh_news_items ||= begin
      stale_threshold = Date.current - 5
      has_news_items? and news_items.results.any? { |news_item| news_item.published_at.to_date >= stale_threshold }
    end
  end

  def method_missing(meth, *args, &block)
    if meth.to_s =~ /^has_(.+)\?$/
      run_has_method($1)
    else
      super
    end
  end

  private
  def run_has_method(member_name)
    send(member_name).present? and send(member_name).total > 0
  end

end
