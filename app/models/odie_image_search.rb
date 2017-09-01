class OdieImageSearch < OdieSearch
  include DefaultModuleTaggable

  self.default_module_tag = 'OASIS'.freeze
  self.default_spelling_module_tag = 'OSPEL'.freeze

  def initialize(options = {})
    super(options)
    @skip_log_serp_impressions = options[:skip_log_serp_impressions]
    @oasis_search = OasisSearch.new(query: @query,
                                    per_page: @per_page,
                                    offset: (@page - 1) * @per_page,
                                    flickr_groups: flickr_groups,
                                    flickr_users: flickr_users,
                                    mrss_names: mrss_names,
                                    instagram_profiles: instagram_profiles)
  end

  def search
    ActiveSupport::Notifications.instrument("oasis_search.usasearch", :query => {
      :term => @query, :affiliate => @affiliate.name, :page => @page }) do
      @oasis_search.execute_query
    end
  rescue SearchEngine::SearchError => error
    Rails.logger.warn "Error getting search results from Oasis API endpoint: #{error}"
    false
  end

  def cache_key
    ["oasis_image", @query, @affiliate.id, @page, @per_page].join(':')
  end

  def handle_response(response)
    super(response)
    assign_spelling_suggestion_if_eligible(response.spelling_suggestion) if response
  end

  def process_results(response)
    image_results = response.results || []
    image_results.collect do |result|
      Hashie::Mash::Rash.new(title: result.title, url: result.url, display_url: result.url,
                       thumbnail: { url: result.thumbnail_url })
    end
  end

  protected

  def log_serp_impressions
    return if @skip_log_serp_impressions

    @modules << default_module_tag unless @total.zero?
  end

  private

  def flickr_groups
    @affiliate.flickr_profiles.groups.collect(&:profile_id)
  end

  def flickr_users
    @affiliate.flickr_profiles.users.collect(&:profile_id)
  end

  def instagram_profiles
    @affiliate.instagram_profiles.collect(&:username)
  end

  def mrss_names
    @affiliate.rss_feeds.mrss.collect(&:rss_feed_urls).flatten.collect(&:oasis_mrss_name).compact
  end
end
