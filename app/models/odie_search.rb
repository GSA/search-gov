class OdieSearch < Search
  include DefaultModuleTaggable

  self.default_module_tag = 'AIDOC'.freeze
  attr_reader :document_collection

  def initialize(options = {})
    super(options)
    @query = (@query || '').squish
    @document_collection = options[:document_collection]
    @total = 0
  end

  def search
    ElasticIndexedDocument.search_for(q: @query,
                                      affiliate_id: @affiliate.id,
                                      document_collection: @document_collection,
                                      include_suggestion: true,
                                      language: @affiliate.indexing_locale,
                                      size: @per_page,
                                      offset: (@page - 1) * @per_page)
  end

  def cache_key
    [@query, @affiliate.id, @page, @document_collection.try(:id)].join(':')
  end

  def handle_response(response)
    if response
      @total = response.total
      @results = paginate(process_results(response))
      @startrecord = ((@page - 1) * @per_page) + 1
      @endrecord = @startrecord + @results.size - 1
      @module_tag = @total > 0 ? default_module_tag : nil
    end
  end

  def process_results(response)
    response.results.collect do |result|
      content_field = !(has_highlight?(result.description)) && has_highlight?(result.body) ? result.body : result.description
      {
        'title' => result.title,
        'unescapedUrl' => result.url,
        'content' => content_field
      }
    end
  end

  protected

  def has_highlight?(field)
    field =~ /\uE000/
  end

  def log_serp_impressions
    @modules << @module_tag if @module_tag
  end
end
