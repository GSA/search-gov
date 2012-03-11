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

  def handle_response(response)
    if response
      @total = response.total
      @startrecord = ((@page - 1) * 10) + 1
      @results = paginate(process_results(response))
      @hits = response.hits(:verify => true)
      @endrecord = @startrecord + @results.size - 1
    end
  end

  def cache_key
    [@query, @affiliate.name, @page].join(':')
  end


  def as_json(options = {})
    if @error_message
      {:error => @error_message}
    else
      {:total => @total, :startrecord => @startrecord, :endrecord => @endrecord, :results => @results}
    end
  end

  def to_xml(options = {:indent => 0, :root => :search})
    if @error_message
      {:error => @error_message}.to_xml(options)
    else
      {:total => @total, :startrecord => @startrecord, :endrecord => @endrecord, :results => @results}.to_xml(options)
    end
  end

  protected

  def process_results(results)
    processed = results.hits(:verify => true).collect do |hit|
      {
        'title' => highlight_solr_hit_like_bing(hit, :title),
        'unescapedUrl' => hit.instance.url,
        'content' => highlight_solr_hit_like_bing(hit, :description),
        'cacheUrl' => nil,
        'deepLinks' => nil
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
