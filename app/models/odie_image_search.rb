class OdieImageSearch < OdieSearch
  include DefaultModuleTaggable

  self.default_module_tag = 'FLICKR'.freeze

  def initialize(options = {})
    super(options)
    @skip_log_serp_impressions = options[:skip_log_serp_impressions] || false
  end

  def search
    ElasticFlickrPhoto.search_for(q: @query,
                                  affiliate_id: @affiliate.id,
                                  language: @affiliate.locale,
                                  size: @per_page,
                                  offset: (@page - 1) * @per_page,
                                  highlighting: false)
  end

  def cache_key
    ["odie_image", @query, @affiliate.id, @page, @per_page].join(':')
  end

  def process_results(response)
    processed = response.results.collect do |result|
      Hashie::Rash.new({
        "title" => result.title,
        "Width" => result.width_o,
        "Height" => result.height_o,
        "FileSize" => 0,
        "ContentType" => "",
        "Url" => result.flickr_url,
        "DisplayUrl" => result.flickr_url,
        "MediaUrl" => result.url_o,
        "Thumbnail" => {
          "Url" => result.url_q,
          "FileSize" => 0,
          "Width" => result.width_q,
          "Height" => result.height_q,
          "ContentType" => ""
        }
      })
    end
    processed.compact
  end

  protected

  def log_serp_impressions
    return if @skip_log_serp_impressions

    @modules << default_module_tag unless @total.zero?
  end
end
