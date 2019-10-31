# frozen_string_literal: true

class ElasticBoostedContentData
  attr_reader :language, :boosted_content

  def initialize(boosted_content)
    @boosted_content = boosted_content
    @language = boosted_content.affiliate.indexing_locale
  end

  def to_builder
    Jbuilder.new do |json|
      json.(boosted_content,
            :id,
            :affiliate_id,
            :status,
            :publish_start_on,
            :publish_end_on,
            :match_keyword_values_only)
      %w[title description].each do |field|
        json.set! "#{field}.#{language}", boosted_content.send(field)
      end
      json.url UrlParser.strip_http_protocols(boosted_content.url)
      json.language language
      json.keyword_values boosted_content.boosted_content_keywords.pluck(:value)
    end
  end
end
