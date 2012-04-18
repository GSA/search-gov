class OdieSearch < Search
  attr_reader :document_collection,
              :hits

  def initialize(options = {})
    super(options)
    @query = (@query || '').squish
    @document_collection = @affiliate.document_collections.navigable_only.find(options[:dc]) rescue nil
    @hits, @total = [], 0
  end

  def search
    IndexedDocument.search_for(@query, @affiliate, @document_collection, @page, 10)
  end

  def cache_key
    [@query, @affiliate.id, @page, @document_collection.try(:id)].join(':')
  end

  protected

  def handle_response(response)
    if response
      @total = response.total
      @results = paginate(process_results(response))
      @hits = response.hits(:verify => true)
      @startrecord = ((@page - 1) * 10) + 1
      @endrecord = @startrecord + @results.size - 1
    end
  end

  def process_results(response)
    processed = response.hits(:verify => true).collect do |hit|
      {
        'title' => highlight_solr_hit_like_bing(hit, :title),
        'unescapedUrl' => hit.instance.url,
        'content' => highlight_solr_hit_like_bing(hit, :description)
      }
    end
    processed.compact
  end

  def log_serp_impressions
    modules = []
    modules << "AIDOC" unless @total.zero?
    QueryImpression.log(:odie, @affiliate.name, @query, modules)
  end
end
