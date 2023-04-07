class OdieSearch < Search
  include DefaultModuleTaggable

  self.default_module_tag = 'AIDOC'.freeze
  # NOTE: For Odie backfill to work on blended sites with commercial results, Odie's default_per_page should
  # remain the same as that of commercial engines. As of 4/2023, the only commercial search engine is
  # Bing, with a count of `20`.
  self.default_per_page = 20
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
    return unless response

    @total = response.total
    @results = paginate(process_results(response))
    @startrecord = ((@page - 1) * @per_page) + 1
    @endrecord = @startrecord + @results.size - 1
    @module_tag = @total.positive? ? default_module_tag : nil
  end

  def process_results(response)
    response.results.collect do |result|
      content_field = !highlighted?(result.description) && highlighted?(result.body) ? result.body : result.description
      {
        'title' => result.title,
        'unescapedUrl' => result.url,
        'content' => content_field
      }
    end
  end

  protected

  def highlighted?(field)
    field =~ /\uE000/
  end

  def log_serp_impressions
    @modules << @module_tag if @module_tag
  end
end
