class BlendedSearch < Search
  include Govboxable

  KLASS_MODULE_MAPPING = { indexed_document: 'AIDOC', news_item: 'NEWS' }

  def initialize(options = {})
    super(options)
    @options = options
    @query = (@query || '').squish
    @total = 0
  end

  def search
    search_options = { q: @query,
                       affiliate_id: @affiliate.id,
                       rss_feed_url_ids: @affiliate.rss_feed_urls.pluck(:id),
                       language: @affiliate.locale,
                       size: @per_page,
                       offset: (@page - 1) * @per_page }
    elastic_blended_results = ElasticBlended.search_for(search_options)
    ensure_no_suggestion_when_results_present(elastic_blended_results)
    if elastic_blended_results && elastic_blended_results.total.zero? && elastic_blended_results.suggestion.present?
      suggestion = elastic_blended_results.suggestion
      elastic_blended_results = ElasticBlended.search_for(search_options.merge(q: suggestion.text))
      elastic_blended_results.override_suggestion(suggestion) if elastic_blended_results
    end
    elastic_blended_results
  end

  def handle_response(response)
    if response
      @total = response.total
      override_plain_odie_description_with_highlighted_body(response.results)
      @results = paginate(response.results)
      @startrecord = ((@page - 1) * @per_page) + 1
      @endrecord = @startrecord + @results.size - 1
      @spelling_suggestion = response.suggestion.highlighted if response.suggestion.present?
    end
  end

  protected
  def populate_additional_results
    @govbox_set = GovboxSet.new(query, affiliate, @options[:geoip_info]) if first_page?
  end

  def override_plain_odie_description_with_highlighted_body(results)
    results.each do |result|
      result.description = result.body if indexed_document_with_hl_body?(result)
    end
  end

  def indexed_document_with_hl_body?(result)
    result.instance_of?(IndexedDocument) && !(has_highlight?(result.description)) && has_highlight?(result.body)
  end

  def has_highlight?(field)
    field =~ /\uE000/
  end

  def log_serp_impressions
    @modules << "LOVER" << "LSPEL" unless self.spelling_suggestion.nil?
    @modules << "SREL" if self.has_related_searches?
    @modules << modules_in_results if @total > 0
    @modules << 'VIDS' if self.has_video_news_items?
    @modules << "BBG" if self.has_featured_collections?
    @modules << "BOOS" if self.has_boosted_contents?
    @modules << "MEDL" unless self.med_topic.nil?
    @modules << "JOBS" if self.jobs.present?
    @modules << "TWEET" if self.has_tweets?
  end

  private

  def modules_in_results
    @results.collect { |result| result.class.name.underscore.to_sym }.uniq.map { |sym| KLASS_MODULE_MAPPING[sym] }
  end

  def ensure_no_suggestion_when_results_present(elastic_blended_results)
    if elastic_blended_results && elastic_blended_results.total > 0 && elastic_blended_results.suggestion.present?
      elastic_blended_results.override_suggestion(nil)
    end
  end

end
