# frozen_string_literal: true

class ElasticBoostedContentQuery < ElasticBestBetQuery
  def initialize(options)
    super(options)
    @text_fields = %w[title description]
    @site_limits = options[:site_limits]
  end

  def filtered_query_filter(json)
    super do
      json.set! :should do |should_json|
        @site_limits.each do |site_limit|
          should_json.child! { should_json.prefix { json.url site_limit } }
        end
      end if @site_limits.present?
    end
  end
end
