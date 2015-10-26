class ElasticBoostedContentData

  def initialize(boosted_content)
    @boosted_content = boosted_content
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@boosted_content, :id, :affiliate_id, :title, :description, :status, :publish_start_on, :publish_end_on, :match_keyword_values_only)
      json.url UrlParser.strip_http_protocols(@boosted_content.url)
      json.language "#{@boosted_content.affiliate.indexing_locale}_analyzer"
      json.keyword_values @boosted_content.boosted_content_keywords.collect(&:value)
    end
  end

end
