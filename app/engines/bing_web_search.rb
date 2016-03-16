class BingWebSearch < BingSearch
  protected

  def params
    params_hash = super
    params_hash.merge!('web.offset' => offset) unless offset == DEFAULT_OFFSET
    params_hash.merge!('web.count' => per_page) unless per_page == DEFAULT_PER_PAGE
    params_hash
  end

  def process_results(response)
    web_results = response.web.results || []
    coder = HTMLEntities.new
    processed = web_results.collect do |result|
      title = coder.decode(result.title) rescue nil
      description = coder.decode(result.description) || ''
      title.present? && result.url.present? ? Hashie::Rash.new({title: title, unescaped_url: result.url, content: description}) : nil
    end
    processed.compact
  end

  def hits(response)
    (response.web.results.blank? ? 0 : response.web.total) rescue 0
  end

  def bing_offset(response)
    (response.web.results.blank? ? 0 : response.web.offset) rescue 0
  end

  def index_sources
    'Spell Web'
  end
end
