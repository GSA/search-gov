class OdieSearch
  attr_reader :query,
              :affiliate,
              :page,
              :results,
              :error_message,
              :total,
              :startrecord,
              :endrecord,
              :queried_at_seconds
              
  def initialize(options = {})
    @query = (options[:query] || '').squish
    @query.downcase! if @query.ends_with? " OR"
    @affiliate = options[:affiliate]
    @page = (options[:page] || "1").to_i
    @results, @hits, @total = [], [], 0
    @queried_at_seconds = Time.now.to_i
  end
  
  def run
    @error_message = (I18n.translate :too_long) and return false if @query.length > Search::MAX_QUERYTERM_LENGTH
    @error_message = (I18n.translate :empty_query) and return false if @query.blank?
    search = IndexedDocument.search_for(@query, @affiliate, @page, 10)
    if search 
      @total = search.total
      @startrecord = ((@page - 1) * 10) + 1
      @results = process_results(search)
      @endrecord = @startrecord + @results.size - 1
    end
    log_serp_impressions
    true
  end
  
  def cache_key
    [@query, @affiliate.name, @startrecord].join(':')
  end

  
  def as_json(options = {})
    if @error_message
      {:error => @error_message}
    else
      {
        :total => @total,
        :startrecord => @startrecord,
        :endrecord => @endrecord,
        :results => @results
      }
    end
  end

  def to_xml(options = {:indent => 0, :root => :search})
    if @error_message
      {:error => @error_message}.to_xml(options)
    else
      {
        :total => @total,
        :startrecord => @startrecord,
        :endrecord => @endrecord,
        :results => @results
      }.to_xml(options)
    end
  end

  private

  def process_results(results)
    processed = results.hits.collect do |hit|
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
  
  def highlight_solr_hit_like_bing(hit, field_symbol)
    return hit.highlights(field_symbol).first.format { |phrase| "\xEE\x80\x80#{phrase}\xEE\x80\x81" } unless hit.highlights(field_symbol).first.nil?
    hit.instance.send(field_symbol)
  end

  
  def log_serp_impressions
    modules = []
    modules << "ODIE" unless @total.zero?
    QueryImpression.log(:odie, @affiliate.name, @query, modules)
  end  
end
