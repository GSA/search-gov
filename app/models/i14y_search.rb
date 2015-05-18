class I14ySearch < Search
  include Govboxable
  I14Y_SUCCESS = 200

  def initialize(options = {})
    super(options)
    @options = options
    @query = (@query || '').squish
    @total = 0
    @limit = options[:limit]
    @offset = options[:offset]
    @highlight_options = options.slice(:pre_tags, :post_tags)
    @highlight_options[:highlighting] = options[:enable_highlighting]
  end

  def search
    search_options = {
      handles: @affiliate.i14y_drawers.pluck(:handle).sort.join(','),
      language: @affiliate.locale,
      query: @query,
      size: detect_size,
      offset: detect_offset
    }
    I14yCollections.search(search_options)
  rescue Faraday::ClientError => e
    Rails.logger.error "I14y search problem: #{e.message}"
    false
  end

  def detect_size
    @limit ? @limit : @per_page
  end

  def detect_offset
    @offset ? @offset : ((@page - 1) * @per_page)
  end

  def first_page?
    @offset ? @offset.zero? : super
  end

  protected

  def handle_response(response)
    if response && response.status == I14Y_SUCCESS
      @total = response.metadata.total
      I14yPostProcessor.new(response.results).post_process_results
      @results = paginate(response.results)
      @startrecord = ((@page - 1) * @per_page) + 1
      @endrecord = @startrecord + @results.size - 1
    end
  end

  def populate_additional_results
    @govbox_set = GovboxSet.new(query,
                                affiliate,
                                @options[:geoip_info],
                                @highlight_options) if first_page?
  end


  def log_serp_impressions
    @modules |= @govbox_set.modules if @govbox_set
    @modules << 'I14Y' if @total > 0
  end

end
