class OdieSearch < Search
  attr_reader :document_collection,
              :hits

  def initialize(options = {})
    super(options)
    @query = (@query || '').squish
    @document_collection = options[:document_collection]
    @hits, @total = [], 0
  end

  def search
    IndexedDocument.search_for(@query, @affiliate, @document_collection, @page, @per_page)
  end

  def cache_key
    [@query, @affiliate.id, @page, @document_collection.try(:id)].join(':')
  end

  def handle_response(response)
    if response
      @total = response.total
      @results = paginate(process_results(response))
      @hits = response.hits(:verify => true)
      @startrecord = ((@page - 1) * 10) + 1
      @endrecord = @startrecord + @results.size - 1
      @module_tag = @total > 0 ? 'AIDOC' : nil
    end
  end

  def process_results(response)
    processed = response.hits(:verify => true).collect do |hit|
      {
        'title' => SolrBingHighlighter.hl(hit, :title),
        'unescapedUrl' => hit.instance.url,
        'content' => SolrBingHighlighter.hl(hit, :description)
      }
    end
    processed.compact
  end

  protected

  def log_serp_impressions
    modules = []
    modules << @module_tag if @module_tag
    QueryImpression.log(:odie, @affiliate.name, @query, modules)
  end
end
