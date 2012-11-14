class OdieImageSearch < OdieSearch
  
  def initialize(options = {})
    super(options)
  end
  
  def search
    FlickrPhoto.search_for(@query, @affiliate, @page, @per_page)
  end
  
  def cache_key
    ["odie_image", @query, @affiliate.id, @page, @per_page].join(':')
  end
  
  def process_results(response)
    processed = response.hits(:verify => true).collect do |hit|
      {        
        "title" => hit.instance.title,
        "Width" => hit.instance.width_o,
        "Height" => hit.instance.height_o,
        "FileSize" => 0,
        "ContentType" => "",
        "Url" => hit.instance.flickr_url,
        "DisplayUrl" => hit.instance.flickr_url,
        "MediaUrl" => hit.instance.url_o,
        "Thumbnail" => {
          "Url" => hit.instance.url_q,
          "FileSize" => 0,
          "Width" => hit.instance.width_q,
          "Height" => hit.instance.height_q,
          "ContentType" => ""
          }
        }
    end
    processed.compact
  end

  protected

  def log_serp_impressions
    modules = []
    modules << "FLICKR" unless @total.zero?
    QueryImpression.log(:odie_image, @affiliate.name, @query, modules)
  end
end