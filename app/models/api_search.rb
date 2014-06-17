class ApiSearch
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
    if (cached = (@@redis.get(@api_cache_key) rescue nil))
      cached
    else
      @search.run
      result = @format == :xml ? @search.to_xml : @search.to_json
      @@redis.setex(@api_cache_key, CACHE_EXPIRATION_IN_SECONDS, result) rescue nil
      result
    end
  end

  private
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
