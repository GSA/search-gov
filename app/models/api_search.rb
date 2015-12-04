class ApiSearch
  include SearchEngineResponseDiagnostics
  delegate :modules,
           :to => :@search,
           :allow_nil => true

  cattr_reader :redis
  @@redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)

  CACHE_EXPIRATION_IN_SECONDS = 5 * 60

  def initialize(options)
    @format = options[:format] =~ /xml/i ? :xml : :json
    search_klass = get_search_klass options[:index]
    @search = search_klass.new(options)
    @api_cache_key = ['API',search_klass, @search.cache_key, @format].join(':')
  end

  def run
    start = Time.now.to_f
    if (result = (@@redis.get(@api_cache_key) rescue nil))
      add_diagnostics_for_cache_result(result, start)
      result
    else
      result = run_search
      add_diagnostics_for_noncache_result(result, start)
      result
    end
  end

  private

  def run_search
    @search.run
    result = @format == :xml ? @search.to_xml : @search.to_json
    @@redis.setex(@api_cache_key, CACHE_EXPIRATION_IN_SECONDS, result) rescue nil
    result
  end

  def add_diagnostics_for_cache_result(result, start)
    elapsed_seconds = Time.now.to_f - start
    diagnostics['APIV1'] = {
      result_count: parse_result_count(result),
      from_cache: 'api_v1_redis',
      elapsed_time_ms: (elapsed_seconds * 1000).to_i,
    }
  end

  def add_diagnostics_for_noncache_result(result, start)
    elapsed_seconds = Time.now.to_f - start
    diagnostics['APIV1'] = {
      result_count: parse_result_count(result),
      from_cache: 'none',
      elapsed_time_ms: (elapsed_seconds * 1000).to_i,
    }
    diagnostics.merge!(@search.diagnostics)
  end

  def parse_result_count(json_or_xml)
    @format == :xml ? xml_result_count(json_or_xml) : json_result_count(json_or_xml)
  end

  def json_result_count(json)
    JSON.parse(json)['results'].length rescue 0
  end

  def xml_result_count(xml)
    Nokogiri::XML::Document.parse(xml).xpath('/search/results/result').size rescue 0
  end

  def get_search_klass(options_index)
    case options_index
      when "news"
        ApiNewsSearch
      when "images"
        ApiLegacyImageSearch
      when "videonews"
        VideoNewsSearch
      when "docs"
        SiteSearch
      else
        WebSearch
    end
  end
end
